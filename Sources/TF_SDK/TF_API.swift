//
//  TF_API.swift
//  
//
//  Created by kin nam on 2022/12/14.
//

import Foundation
import Alamofire
extension TF_API {
    ///웹소켓 접속키 발급
    public struct Approval:APIITEM, AdditionalExec {
        public let server: TargetServer = .hantoo
        
        public struct Request:Codable {
            public var grant_type:String = "client_credentials"
            public let appkey:String
            public let secretkey:String
        }
        public struct Response:Codable {
            public let approval_key:String
        }
        public var requestHeaderModel = EmptyModel.self
        public var responseHeaderModel = EmptyModel.self
        public var requestModel = Request.self
        public var responseModel = Response.self
        public var method: Alamofire.HTTPMethod = .post
        public var path: String = "/oauth2/Approval"
        public func exec(response: Decodable) {
            guard let result = response as? Response else {return}
            TF_User.shared.approval_key = result.approval_key
        }
    }
    ///해쉬키(Hashkey)는 보안을 위한 요소로 사용자가 보낸 요청 값을 중간에 탈취하여 변조하지 못하도록 하는데 사용됩니다. 보안을 위해 POST로 보내는 요청(주로 주문/정정/취소 API 해당)은 사전에 body 값 암호화가 필요하며, 이 때 hashkey를 활용한 암호화를 진행합니다.
    public struct hashkey:APIITEM {
        public var server: TargetServer = .hantoo
        
        public struct Response:Codable {
            public let jsonBody:String
            public let HASH:String
        }
        public var requestHeaderModel = EmptyModel.self
        public var responseHeaderModel = EmptyModel.self
        public var requestModel = Data.self
        public var responseModel = Response.self
        public var method: Alamofire.HTTPMethod = .post
        public var path: String = "/uapi/hashkey"
    }
    ///접근토큰 발급
    public struct tokenP:APIITEM, AdditionalExec {
        public var server: TargetServer = .hantoo
        
        public struct Request:Codable {
            public let grant_type:String = "client_credentials"
            public let appkey:String
            public let appsecret:String
        }
        public struct Response:Codable {
            public let access_token:String
            public let token_type:String
            public let expires_in:Int
        }
        public var requestHeaderModel = EmptyModel.self
        public var responseHeaderModel = EmptyModel.self
        public var requestModel = Request.self
        public var responseModel = Response.self
        public var method: Alamofire.HTTPMethod = .post
        public var path: String = "/oauth2/tokenP"
        public func exec(response: Decodable) {
            guard let result = response as? Response else {return}
            TF_User.shared.access_token = result.access_token
            TF_User.shared.token_type = result.token_type
        }
    }
    ///주식 잔고조회 API입니다. 실전계좌의 경우, 한 번의 호출에 최대 50건까지 확인 가능하며, 이후의 값은 연속조회를 통해 확인하실 수 있습니다. 모의계좌의 경우, 한 번의 호출에 최대 20건까지 확인 가능하며, 이후의 값은 연속조회를 통해 확인하실 수 있습니다.
    public struct inquire_balance:APIITEM {
        public var server: TargetServer = .hantoo
        public struct RequestHeader:Codable {
            ///고객식별키
            public var personalseckey:String?
            ///거래ID
            public var tr_id:String = hantooType == .실전 ? "TTTC8434R" : "VTTC8434R"
            ///연속 거래 여부
            public var tr_cont:String?
            ///고객타입
            public var custtype:String?
            ///일련번호
            public var seq_no:String?
            ///맥주소
            public var mac_address:String?
            ///핸드폰번호
            public var phone_number:String?
            ///접속 단말 공인 IP
            public var ip_addr:String?
            ///Global UID
            public var gt_uid:String?
            public init(personalseckey: String? = nil, tr_id: String, tr_cont: String? = nil, custtype: String? = nil, seq_no: String? = nil, mac_address: String? = nil, phone_number: String? = nil, ip_addr: String? = nil, gt_uid: String? = nil) {
                self.personalseckey = personalseckey
                self.tr_id = tr_id
                self.tr_cont = tr_cont
                self.custtype = custtype
                self.seq_no = seq_no
                self.mac_address = mac_address
                self.phone_number = phone_number
                self.ip_addr = ip_addr
                self.gt_uid = gt_uid
            }
        }
        public struct Request:Codable {
            ///종합계좌번호
            public var CANO:String
            ///계좌상품코드
            public var ACNT_PRDT_CD:String
            ///시간외단일가여부
            public var AFHR_FLPR_YN:String
            ///오프라인여부
            public var OFL_YN:String
            ///조회구분
            public var INQR_DVSN:String
            ///단가구분
            public var UNPR_DVSN:String
            ///펀드결제분포함여부
            public var FUND_STTL_ICLD_YN:String
            ///융자금액자동상환여부
            public var FNCG_AMT_AUTO_RDPT_YN:String
            ///처리구분
            public var PRCS_DVSN:String
            ///연속조회검색조건100
            public var CTX_AREA_FK100:String
            ///연속조회키100
            public var CTX_AREA_NK100:String
        }
        public struct ResponseHeader:Codable {
            ///거래ID
            public let tr_id:String
            ///연속 거래 여부
            public let tr_cont:String
            ///Global UID
            public let gt_uid:String
        }
        public struct Output1:Codable {
            ///상품번호
            public let pdno:String
            ///상품명
            public let prdt_name:String
            ///매매구분명
            public let trad_dvsn_name:String
            ///전일매수수량
            public let bfdy_buy_qty:String
            ///전일매도수량
            public let bfdy_sll_qty:String
            ///금일매수수량
            public let thdt_buyqty:String
            ///금일매도수량
            public let thdt_sll_qty:String
            ///보유수량
            public let hldg_qty:String
            ///주문가능수량
            public let ord_psbl_qty:String
            ///매입평균가격
            public let pchs_avg_pric:String
            ///매입금액
            public let pchs_amt:String
            ///현재가
            public let prpr:String
            ///평가금액
            public let evlu_amt:String
            ///평가손익금액
            public let evlu_pfls_amt:String
            ///평가손익율
            public let evlu_pfls_rt:String
            ///평가수익율
            public let evlu_erng_rt:String
            ///대출일자
            public let loan_dt:String
            ///대출금액
            public let loan_amt:String
            ///대주매각대금
            public let stln_slng_chgs:String
            ///만기일자
            public let expd_dt:String
            ///등락율
            public let fltt_rt:String
            ///전일대비증감
            public let bfdy_cprs_icdc:String
            ///종목증거금율명
            public let item_mgna_rt_name:String
            ///보증금율명
            public let grta_rt_name:String
            ///대용가격
            public let sbst_pric:String
            ///주식대출단가
            public let stck_loan_unpr:String
        }
        public struct Output2:Codable {
            ///예수금총금액
            public let dnca_tot_amt:String
            ///익일정산금액
            public let nxdy_excc_amt:String
            ///가수도정산금액
            public let prvs_rcdl_excc_amt:String
            ///CMA평가금액
            public let cma_evlu_amt:String
            ///전일매수금액
            public let bfdy_buy_amt:String
            ///금일매수금액
            public let thdt_buy_amt:String
            ///익일자동상환금액
            public let nxdy_auto_rdpt_amt:String
            ///전일매도금액
            public let bfdy_sll_amt:String
            ///금일매도금액
            public let thdt_sll_amt:String
            ///D+2자동상환금액
            public let d2_auto_rdpt_amt:String
            ///전일제비용금액
            public let bfdy_tlex_amt:String
            ///금일제비용금액
            public let thdt_tlex_amt:String
            ///총대출금액
            public let tot_loan_amt:String
            ///유가평가금액
            public let scts_evlu_amt:String
            ///총평가금액
            public let tot_evlu_amt:String
            ///순자산금액
            public let nass_amt:String
            ///융자금자동상환여부
            public let fncg_gld_auto_rdpt_yn:String
            ///매입금액합계금액
            public let pchs_amt_smtl_amt:String
            ///평가금액합계금액
            public let evlu_amt_smtl_amt:String
            ///평가손익합계금액
            public let evlu_pfls_smtl_amt:String
            ///총대주매각대금
            public let tot_stln_slng_chgs:String
            ///전일총자산평가금액
            public let bfdy_tot_asst_evlu_amt:String
            ///자산증감액
            public let asst_icdc_amt:String
            ///자산증감수익율
            public let asst_icdc_erng_rt:String
        }
        public struct Response:Codable {
            ///성공 실패 여부
            public let rt_cd:String
            ///응답코드
            public let msg_cd:String
            ///응답메세지
            public let msg1:String
            ///연속조회검색조건100
            public let ctx_area_fk100:String
            ///연속조회키100
            public let ctx_area_nk100:String
            ///output1
            public let output1:[Output1]
            ///output2
            public let output2:[Output2]
        }
        public var requestHeaderModel = RequestHeader.self
        public var responseHeaderModel = ResponseHeader.self
        public var requestModel = Request.self
        public var responseModel = Response.self
        public var method: Alamofire.HTTPMethod = .get
        public var path: String = "/uapi/domestic-stock/v1/trading/inquire-balance"
    }
}
