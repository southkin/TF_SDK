
import Alamofire
import Then
import Foundation

public enum HantooType {
    case 실전
    case 모의
}
public struct EmptyModel:Codable {
}

public struct ErrorResponse : Error, Decodable {
    let rt_cd:String
    let msg_cd:String
    let msg1:String
}
var hantooType:HantooType = .실전
public enum TargetServer {
    case hantoo
    var domain:String {
        switch self {
        case .hantoo:
            return hantooType == .실전 ? "https://openapi.koreainvestment.com:9443" : "https://openapivts.koreainvestment.com:29443"
        }
    }
    var defaultHeader:HTTPHeaders {
        switch self {
        case .hantoo:
            return [
                "Content-Type" : "application/json; charset=UTF-8",
                "authorization" : "\(TF_User.shared.token_type ?? "") \(TF_User.shared.access_token ?? "")",
                "appkey" : TF_User.shared.appKey ?? "",
                "appsecret" : TF_User.shared.appSecret ?? ""
            ]
        }
    }
    func errorChecker(response:Data,curlCmd:String,retryFnc:(()->())?) -> ErrorResponse? {
        let info = try? response.makeObj(type: ErrorResponse.self)
        switch Int(info?.rt_cd ?? "0")! {
        case 0:
            return nil
        case 1:
            TF_API.tokenP().request(headerArg: .init(), arg: .init(appkey: TF_User.shared.appKey ?? "", appsecret: TF_User.shared.appSecret ?? "")) { header, body, error in
                retryFnc?()
            }
            return info
        default:
            return info
        }
    }
}
struct MultipartItem : Codable {
    var data:Data
    var mimeType:String
    var fileName:String?
}
protocol MultipartUpload {
}
protocol AdditionalExec {
    func exec(response:Decodable)
}
protocol HashAdd {
}
extension HashAdd {
    func preExec(headers:HTTPHeaders,body:Data,url:URL,run:@escaping(HTTPHeaders,Data,URL)->()) {
        var headers = headers
    }
}
fileprivate var API_STORED_DATA:[String:(Decodable,Decodable)] = .init()
public protocol APIITEM_BASE {
    var method:Alamofire.HTTPMethod {get}
    var server:TargetServer {get}
    var path:String {get}
    var header:Alamofire.HTTPHeaders? {get}
    var errorChecker:(Data,String,(()->())?)->(ErrorResponse?) {get}
    var paramEncoder:ParameterEncoder {get}
    var strEncoder:String.Encoding {get}
    var usingStoredData:Bool {get}
}
public extension APIITEM_BASE {
    var errorChecker:(Data,String,(()->())?)->(ErrorResponse?) {
        {return self.server.errorChecker(response: $0,curlCmd: $1,retryFnc: $2)}
    }
    var header:HTTPHeaders? {
        return self.server.defaultHeader
    }
    var usingStoredData:Bool {
        return false
    }
    var paramEncoder:ParameterEncoder {
        return JSONParameterEncoder()
    }
    var strEncoder:String.Encoding {
        .utf8
    }
}
public protocol APIITEM : APIITEM_BASE {
    associatedtype ResponseModel : Decodable
    associatedtype RequestModel : Encodable
    associatedtype ResponseHeaderModel : Decodable
    associatedtype RequestHeaderModel : Encodable
    var responseModel:ResponseModel.Type {get}
    var requestModel:RequestModel.Type {get}
    var responseHeaderModel:ResponseHeaderModel.Type {get}
    var requestHeaderModel:RequestHeaderModel.Type {get}
}
public extension APIITEM {
    func makeHeader(headerArg:RequestHeaderModel?) -> HTTPHeaders {
        var headers = server.defaultHeader
        headerArg?.allProperties.forEach {
            guard let value = $0.1 as? String else {return}
            headers.add(name: $0.0, value: value)
        }
        return headers
    }
    public func request(retryCnt:Int = 0, headerArg:RequestHeaderModel, arg:RequestModel,callback:@escaping(ResponseHeaderModel?,ResponseModel?,NSError?)->Void){
        let usingUrlSession = false
        var curlText:String?
        if usingStoredData, let storedData = API_STORED_DATA[String(describing:self)] {
            callback(storedData.0 as? Self.ResponseHeaderModel,storedData.1 as? Self.ResponseModel,nil)
            return
        }
        guard var url = "\(server.domain)\(path)".makeURL else {
            print("/////////")
            print("url 변환 실패(\(server.domain)\(path)")
            print("/////////")
            return
        }
        var isDone = false
        var param:RequestModel? = arg
        if self.method == .get, var comp = URLComponents(url: url, resolvingAgainstBaseURL: false){
            param = nil
            
            comp.queryItems = {
                comp.queryItems ?? .init()
            }()
            for prop in arg.allProperties {
                if let str = prop.1 as? String {
                    
                    comp.queryItems?.append(.init(name: prop.0, value: str))
                }
            }
            url = comp.url ?? url
        }
        let complition = { (response:AFDataResponse<Data>) in
            var headerList:[String:String] = .init()
            response.response?.allHeaderFields.forEach {
                guard let key = $0.key as? String, let value = $0.value as? String else {return}
                headerList[key] = value
            }
            let headerObj = try? headerList.data.makeObj(type:self.responseHeaderModel.self)
            defer {
                isDone = true
            }
            if let err = response.error {
                
                callback(nil,nil,err as NSError)
                if err.localizedDescription != "Response could not be serialized, input data was nil or zero length." {
                    print(err.localizedDescription)
                    print(curlText ?? "")
                }
                return
            }
            guard let data = response.data else {
                print("data not found")
                callback(nil,nil,NSError.init(domain: "data not found", code: 0, userInfo: ["url":url]))
                print(curlText ?? "")
                return
            }
            
            if let apiLayerErr = errorChecker(data,curlText ?? "",{
                guard retryCnt < 3 else {return}
                self.request(retryCnt:retryCnt+1 ,headerArg: headerArg, arg: arg, callback: callback)
            }) {
                print(apiLayerErr.localizedDescription)
                callback(nil,nil,NSError.init(domain: "apiLayerError", code: apiLayerErr.rt_cd.intValue ?? 0, userInfo: [
                    "url":url,
                    "info":apiLayerErr,
                    "msg":apiLayerErr.msg1
                ]))
                return
            }
            
            let deCoder = JSONDecoder()
            deCoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.date(from: dateStr) ?? .init()
            })
            do {
                if self.responseModel is String.Type {
                    let str = String(data: data, encoding: strEncoder) ?? String(decoding:data, as: UTF8.self)
                    print(str)
                    callback(headerObj,str as? Self.ResponseModel,nil)
                    if usingStoredData {
                        API_STORED_DATA[String(describing:self)] = (headerObj,str as? Self.ResponseModel)
                    }
                }
                else {
                    let result = try deCoder.decode(ResponseModel.self, from: data)
                    callback(headerObj,result,nil)
                    print(String(data: data, encoding: .utf8) as Any)
                    if usingStoredData {
                        API_STORED_DATA[String(describing:self)] = (headerObj,result)
                    }
                    if let additional = self as? AdditionalExec {
                        additional.exec(response: result)
                    }
                }
            }
            catch {
                if ResponseModel.self != EmptyModel.self {
                    print("decode fail(url : \(url), model : \(ResponseModel.self))")
                    print(error)
                    print("request : \(arg))")
                    print("response")
                    print(String(data: data, encoding: strEncoder) ?? "")
                }
                callback(nil,nil,error as NSError)
            }
        }
        if self is MultipartUpload {
            let formDataMaker = { (multipartFormData:MultipartFormData) in
                for (key,value) in arg.allProperties {
                    switch value as Any{
                    case let value as MultipartItem:
                        if let filename = value.fileName {
                            multipartFormData.append(value.data, withName: key, fileName: filename, mimeType: value.mimeType)
                        }
                        else {
                            multipartFormData.append(value.data, withName: key, mimeType: value.mimeType)
                        }
                        break
                    case let value as String:
                        guard let data = value.data(using: .utf8) else {continue}
                        multipartFormData.append(data, withName: key, mimeType: "plane/text")
                        break
                    case let value as Int:
                        guard let data = "\(value)".data(using: .utf8) else {continue}
                        multipartFormData.append(data, withName: key, mimeType: "plane/text")
                        break
                    case let value as Codable:
                        let data = value.data
                        multipartFormData.append(data, withName: key, mimeType: "application/json")
                        break
                    default:
                        break
                    }
                }
            }
            AF.upload(multipartFormData: formDataMaker, to: url, method: method, headers: header).responseData(completionHandler: complition).cURLDescription() {
                print("===curlDescription===")
                print($0)
                curlText = $0
            }
        }
        else {
            switch self {
            case let this as HashAdd:
                this.preExec(headers: makeHeader(headerArg: headerArg), body: param?.data ?? .init(), url: url) { headers, data, url in
                    var req = URLRequest(url: url)
                    req.headers = headers
                    req.httpBody = data
                    AF.request(req).cURLDescription() {
                        print("===curlDescription===")
                        print($0)
                        curlText = $0
                    }
                }
                break
            default:
                AF.request(url, method: method, parameters: param, encoder: self.paramEncoder, headers: makeHeader(headerArg: headerArg), interceptor: nil).responseData(completionHandler: complition).cURLDescription() {
                    print("===curlDescription===")
                    print($0)
                    curlText = $0
                }
                break
            }
            
        }
    }
}



public struct TF_API {
}


