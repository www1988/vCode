//
//  RequestSender.swift
//  vCode
//
//  Created by DarkTango on 5/12/15.
//  Copyright (c) 2015 ruitaocc. All rights reserved.
//

import Foundation
class RequestSender:NSObject{
    static var shortURL:String = ""
    static var baseURL:String = "http://2vma.co"
    override init(){
        println("init for sender")
    }
    
    deinit{
        println("deinit for sender")
    }
    
    class func sendRequest()->Bool{
        
        var uuid:String = "123"
        var message:String = ""
        var url:String = ""
        var vcard:String = ""
        var img:NSData
        var tm:String = ""
        var sign:String = ""
        
        let uploadType:String = NSUserDefaults.standardUserDefaults().objectForKey("uploadType") as! String
        
        //set tm

        let dat:NSDate = NSDate(timeIntervalSinceNow: 0)
        let a:NSTimeInterval = dat.timeIntervalSince1970
        tm = String(stringInterpolationSegment: a)
        tm = tm.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        println("tm: "+tm)
        
        //set sign
        let secretKey:String = "C10-705"
        sign = md5Encryptor.md5(secretKey+tm+uuid)
        
        let request = NSMutableURLRequest();
        
        
        //set upload params
        switch uploadType{
        case "txt":
            request.URL = NSURL(string: "http://2vma.co/api/message")
            message = NSUserDefaults.standardUserDefaults().objectForKey("text") as! String
            println(message)
        case "url":
            request.URL = NSURL(string: "http://2vma.co/api/short_url")
            url = NSUserDefaults.standardUserDefaults().objectForKey("url") as! String
            println(url)
        case "qrcode":
            RequestSender.shortURL = ""
        case "image":
            break
        default:
            break
        }
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let postData = "tm="+tm+"&uuid="+uuid+"&sign="+sign+"&message="+message+"&url="+url+"&vcard="+vcard
        //let postData = "tm=111&uuid=123&sign=1339ba084d895328187e53d1fe497d77&url=http://www.baidu.com"
        request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response,data,error) in
            
            if (error != nil){
                println(error)
                self.alert(error.localizedDescription, button: "OK")
                return
                
            }
            let strdata = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println(strdata)
            if let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary{
                println(strdata)
                println(json)
                println(json["code"])
                //NSString* encodedata = [[json objectForKey:@"data"] objectForKey:@"shortUrl"];
                if let code = json["code"] as? NSNumber{
                    //println("in")
                    if code != 0{
                        println("code error")
                        self.shortURL = ""
                    }
                    else{
                        if let data = json["data"] as? NSDictionary{
                            if let url = data["shortUrl"] as? String{
                                self.shortURL = self.baseURL+url
                            }
                        }
                    }
                }
                NSNotificationCenter.defaultCenter().postNotificationName("didReceiveURL", object: self)
                println(self.shortURL)
            }
            else{
                self.alert("Unexpected Error", button: "OK")
                return
            }
        })
        if shortURL == ""{
            return false
        }
        else{
            return true
        }
        
    }
    
    func url()->String{
        return RequestSender.shortURL;
    }
    
    class func alert(title:String,button:String){
        let alert = UIAlertView()
        alert.title = title
        alert.addButtonWithTitle(button)
        alert.show()
        return

    }
}
