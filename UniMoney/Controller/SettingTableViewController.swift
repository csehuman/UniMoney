//
//  SettingTableViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import UserNotifications

class SettingTableViewController: UITableViewController {
    @IBOutlet weak var notiCell: UITableViewCell!
    @IBOutlet weak var askCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UISwitch(frame: .zero)
        v.onTintColor = .systemPurple
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
          if settings.authorizationStatus == .authorized {
              DispatchQueue.main.async {
                  if UserDefaults.standard.bool(forKey: "notiSet") {
                      v.isOn = true
                  } else {
                      v.isOn = false
                  }
              }
          }
          else {
              DispatchQueue.main.async {
                  v.isOn = false
              }
          }
        }
        notiCell.accessoryView = v
        
        v.addTarget(self, action: #selector(toggleNoti(_:)), for: .valueChanged)

    }
    
    @objc func toggleNoti(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { [weak self] granted, error in
                if granted {
                    let content = UNMutableNotificationContent()
                    content.title = "오늘의 가계부 작성을 완료하셨나요?"
                    content.body = "유니머니로 오늘의 가계부를 작성해보세요."
                    
                    let calendar = Calendar.current
                    var dateComponents = DateComponents()
                    dateComponents.hour = 21
                    dateComponents.minute = 00
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request = UNNotificationRequest(identifier: "everyNightNoti", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("ERROR \(String(describing: error.localizedDescription))")
                        }
                    }
                    UserDefaults.standard.set(true, forKey: "notiSet")
                } else {
                    let alert = UIAlertController(title: "설정 > 유니미에서 알림을 허용해주세요.", message: nil, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "확인", style: .default) { action in
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                    alert.addAction(okAction)
                    DispatchQueue.main.async {
                        sender.isOn = false
                        self?.present(alert, animated: true)
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UserDefaults.standard.set(false, forKey: "notiSet")
        }
    }
}
