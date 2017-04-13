//
//  ViewController.swift
//  ios
//
//  Created by sangjun_lee on 2017/04/12.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//

import UIKit
import AFNetworking
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var output: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    private var sentences:[Sentence] = [Sentence]()
    
    private var url = "https://h50yoomb24.execute-api.ap-northeast-1.amazonaws.com/Prod/resource"
    
    
    private var realm: Realm!
    private var dailys: Results<Daily>!
    
    private var token: NotificationToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Realm init
        do {
            realm = try Realm()
        } catch {
            print("\(error)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // print("dailys.count \(dailys.count)")
        
        // print("dailys \(dailys)")
        
        // print("week \(week)")
        
        
        let deldiff = -7
        let getdiff = 0
        
        delDaily(today: getDateformat(today: getDiffDate(diff: deldiff), dateFormat: "yyyyMMdd"))
        let diffDate = getDiffDate(diff: getdiff)
        let endDate = getDateformat(today: diffDate, dateFormat: "yyyyMMdd")
        
        dailys = realm.objects(Daily.self).filter("date <= \(endDate)").sorted(byKeyPath: "date")
        
        //mon-sat : 6
        if (dailys.count >= 6) {
            print("cache!")
            for i in 0..<dailys.count {
                let daily = dailys[i]
                sentences = Array(daily.sentences);
            }
        } else {
            var weekDays = getWeekDays()
            //let week = getDayOfWeek(today: diffDate)
            for i in 0..<dailys.count {
                print("dailys[i].date : \(dailys[i].date)")
                weekDays.removeValue(forKey: String(dailys[i].date))
            }
            
            for key in weekDays.keys {
                if (getDayOfWeek(today: weekDays[key]!) != 1) {
                    getSentences(day: getDateformat(today: weekDays[key]!, dateFormat: "yyyyMMdd"))
                }
            }
        }

        
    }
    
    func getSentences(day: String) {
        // requset
        print("AFNetwork Starts First Page!!!")
        
        
        let manager = AFHTTPSessionManager()
        
        manager.get(
            "\(url)/\(day)",
            parameters: nil,
            progress: nil,
            success:
            {
                (operation, responseObject) in
                print("success")
                
                if let dict = responseObject as? NSDictionary{
                    print("dict of count : \(dict.count)")
                    
                    let tmp_keys = dict.allKeys as! [String]
                    let keys = self.kSort(arr: tmp_keys)
                    
                    if dict.count > 0 {
                        let daily = Daily()
                        daily.date = Int(day)!
                        for key in keys {
                            let dic = dict[String(key)] as! [String : String]
                            
                            let ko = dic["ko"]
                            let en = dic["en"]
                            print("dic :  \(dic)")
                            
                            let sentence = Sentence()
                            sentence.ko = ko!
                            sentence.en = en!
                            self.sentences.append(sentence)
                            daily.sentences.append(sentence)
                        }
                        
                        try! self.realm.write() {
                            self.realm.add(daily)
                        }
                    }

                    self.tableView.reloadData()
                }
        },
            failure:
            {
                (operation, error) in
                print("Error: " + error.localizedDescription)
        }
        )
    }
    
    //MARK: table
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // cell of number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return texts.count
        return sentences.count
    }
    
    // cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.setCell(sentence: sentences[indexPath.row])
        cell.hideShow()
        
        return cell
    }
    
    // cell touch
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomCell
        cell.hideShow()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // key sort
    func kSort(arr : [String]) -> [Int]{
        var keys:[Int] = [Int]()
        for key in arr {
            keys.append(Int(key)!)
        }
        keys = keys.sorted { $0 < $1 }
        return keys
    }
    
    func getWeekDays() -> Dictionary<String, Date> {
        var weekDays = Dictionary<String, Date>()
        
        for i in 0 ..< 7 {
            let diffDate = getDiffDate(diff: (i * -1))
            let endDate = getDateformat(today: diffDate, dateFormat: "yyyyMMdd")
            weekDays[endDate] = diffDate
        }
        
        return weekDays
    }
    
    func getDiffDate(diff : Int) -> Date {
        let now = NSDate()
        let cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let diffDate = cal.date(byAdding: .day, value: diff, to: now as Date, options: NSCalendar.Options())
        return diffDate!
    }
    
    func getDateformat(today: Date, dateFormat: String) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = dateFormat
        print("days \(outputFormatter.string(from: today))")
        
        return outputFormatter.string(from: today)
    }
    
    
    func getDayOfWeek(today : Date) -> Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: today)
        let weekDay = myComponents.weekday
        return weekDay!
    }
    
    func delDaily(today: String) {
        print("del : \(today)")
        let delDaily = realm.objects(Daily.self).filter("date <= \(today)").sorted(byKeyPath: "date")
        try! realm.write() {
            realm.delete(delDaily)
        }
    }
}

