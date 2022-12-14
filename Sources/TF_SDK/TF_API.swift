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
            var grant_type:String = "client_credentials"
            let appkey:String
            let secretkey:String
        }
        public struct Response:Codable {
            let approval_key:String
        }
        public var requestHeaderModel = EmptyModel.self
        public var responseHeaderModel = EmptyModel.self
        public var requestModel = Request.self
        public var responseModel = Response.self
        public var method: Alamofire.HTTPMethod = .post
        public var path: String = "/oauth2/Approval"
        func exec(response: Decodable) {
            guard let result = response as? Response else {return}
            TF_User.shared.approval_key = result.approval_key
        }
    }
    ///해쉬키(Hashkey)는 보안을 위한 요소로 사용자가 보낸 요청 값을 중간에 탈취하여 변조하지 못하도록 하는데 사용됩니다. 보안을 위해 POST로 보내는 요청(주로 주문/정정/취소 API 해당)은 사전에 body 값 암호화가 필요하며, 이 때 hashkey를 활용한 암호화를 진행합니다.
    struct hashkey:APIITEM {
        var server: TargetServer = .hantoo
        
        struct Response:Codable {
            let jsonBody:String
            let HASH:String
        }
        var requestHeaderModel = EmptyModel.self
        var responseHeaderModel = EmptyModel.self
        var requestModel = Data.self
        var responseModel = Response.self
        var method: Alamofire.HTTPMethod = .post
        var path: String = "/uapi/hashkey"
    }
    ///접근토큰 발급
    struct tokenP:APIITEM, AdditionalExec {
        var server: TargetServer = .hantoo
        
        struct Request:Codable {
            let grant_type:String = "client_credentials"
            let appkey:String
            let appsecret:String
        }
        struct Response:Codable {
            let access_token:String
            let token_type:String
            let expires_in:Int
        }
        var requestHeaderModel = EmptyModel.self
        var responseHeaderModel = EmptyModel.self
        var requestModel = Request.self
        var responseModel = Response.self
        var method: Alamofire.HTTPMethod = .post
        var path: String = "/oauth2/tokenP"
        func exec(response: Decodable) {
            guard let result = response as? Response else {return}
            TF_User.shared.access_token = result.access_token
            TF_User.shared.token_type = result.token_type
        }
    }
    ///주식 잔고조회 API입니다. 실전계좌의 경우, 한 번의 호출에 최대 50건까지 확인 가능하며, 이후의 값은 연속조회를 통해 확인하실 수 있습니다. 모의계좌의 경우, 한 번의 호출에 최대 20건까지 확인 가능하며, 이후의 값은 연속조회를 통해 확인하실 수 있습니다.
    struct inquire_balance:APIITEM {
        var server: TargetServer = .hantoo
        struct RequestHeader:Codable {
            ///고객식별키
            var personalseckey:String?
            ///거래ID
            var tr_id:String = hantooType == .실전 ? "TTTC8434R" : "VTTC8434R"
            ///연속 거래 여부
            var tr_cont:String?
            ///고객타입
            var custtype:String?
            ///일련번호
            var seq_no:String?
            ///맥주소
            var mac_address:String?
            ///핸드폰번호
            var phone_number:String?
            ///접속 단말 공인 IP
            var ip_addr:String?
            ///Global UID
            var gt_uid:String?
        }
        struct Request:Codable {
            ///종합계좌번호
            var CANO:String
            ///계좌상품코드
            var ACNT_PRDT_CD:String
            ///시간외단일가여부
            var AFHR_FLPR_YN:String
            ///오프라인여부
            var OFL_YN:String
            ///조회구분
            var INQR_DVSN:String
            ///단가구분
            var UNPR_DVSN:String
            ///펀드결제분포함여부
            var FUND_STTL_ICLD_YN:String
            ///융자금액자동상환여부
            var FNCG_AMT_AUTO_RDPT_YN:String
            ///처리구분
            var PRCS_DVSN:String
            ///연속조회검색조건100
            var CTX_AREA_FK100:String
            ///연속조회키100
            var CTX_AREA_NK100:String
        }
        struct ResponseHeader:Codable {
            ///거래ID
            let tr_id:String
            ///연속 거래 여부
            let tr_cont:String
            ///Global UID
            let gt_uid:String
        }
        struct Output1:Codable {
            ///상품번호
            let pdno:String
            ///상품명
            let prdt_name:String
            ///매매구분명
            let trad_dvsn_name:String
            ///전일매수수량
            let bfdy_buy_qty:String
            ///전일매도수량
            let bfdy_sll_qty:String
            ///금일매수수량
            let thdt_buyqty:String
            ///금일매도수량
            let thdt_sll_qty:String
            ///보유수량
            let hldg_qty:String
            ///주문가능수량
            let ord_psbl_qty:String
            ///매입평균가격
            let pchs_avg_pric:String
            ///매입금액
            let pchs_amt:String
            ///현재가
            let prpr:String
            ///평가금액
            let evlu_amt:String
            ///평가손익금액
            let evlu_pfls_amt:String
            ///평가손익율
            let evlu_pfls_rt:String
            ///평가수익율
            let evlu_erng_rt:String
            ///대출일자
            let loan_dt:String
            ///대출금액
            let loan_amt:String
            ///대주매각대금
            let stln_slng_chgs:String
            ///만기일자
            let expd_dt:String
            ///등락율
            let fltt_rt:String
            ///전일대비증감
            let bfdy_cprs_icdc:String
            ///종목증거금율명
            let item_mgna_rt_name:String
            ///보증금율명
            let grta_rt_name:String
            ///대용가격
            let sbst_pric:String
            ///주식대출단가
            let stck_loan_unpr:String
        }
        struct Output2:Codable {
            ///예수금총금액
            let dnca_tot_amt:String
            ///익일정산금액
            let nxdy_excc_amt:String
            ///가수도정산금액
            let prvs_rcdl_excc_amt:String
            ///CMA평가금액
            let cma_evlu_amt:String
            ///전일매수금액
            let bfdy_buy_amt:String
            ///금일매수금액
            let thdt_buy_amt:String
            ///익일자동상환금액
            let nxdy_auto_rdpt_amt:String
            ///전일매도금액
            let bfdy_sll_amt:String
            ///금일매도금액
            let thdt_sll_amt:String
            ///D+2자동상환금액
            let d2_auto_rdpt_amt:String
            ///전일제비용금액
            let bfdy_tlex_amt:String
            ///금일제비용금액
            let thdt_tlex_amt:String
            ///총대출금액
            let tot_loan_amt:String
            ///유가평가금액
            let scts_evlu_amt:String
            ///총평가금액
            let tot_evlu_amt:String
            ///순자산금액
            let nass_amt:String
            ///융자금자동상환여부
            let fncg_gld_auto_rdpt_yn:String
            ///매입금액합계금액
            let pchs_amt_smtl_amt:String
            ///평가금액합계금액
            let evlu_amt_smtl_amt:String
            ///평가손익합계금액
            let evlu_pfls_smtl_amt:String
            ///총대주매각대금
            let tot_stln_slng_chgs:String
            ///전일총자산평가금액
            let bfdy_tot_asst_evlu_amt:String
            ///자산증감액
            let asst_icdc_amt:String
            ///자산증감수익율
            let asst_icdc_erng_rt:String
        }
        struct Response:Codable {
            ///성공 실패 여부
            let rt_cd:String
            ///응답코드
            let msg_cd:String
            ///응답메세지
            let msg1:String
            ///연속조회검색조건100
            let ctx_area_fk100:String
            ///연속조회키100
            let ctx_area_nk100:String
            ///output1
            let output1:[Output1]
            ///output2
            let output2:[Output2]
        }
        var requestHeaderModel = RequestHeader.self
        var responseHeaderModel = ResponseHeader.self
        var requestModel = Request.self
        var responseModel = Response.self
        var method: Alamofire.HTTPMethod = .get
        var path: String = "/uapi/domestic-stock/v1/trading/inquire-balance"
    }
}
