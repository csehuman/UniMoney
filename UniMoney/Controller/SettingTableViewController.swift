//
//  SettingTableViewController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit
import MessageUI
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
                    
                    dateComponents.calendar = calendar
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            guard MFMailComposeViewController.canSendMail() else {
                showEmailAlert()
                return
            }
            
            let today = DateManager.shared.getTodayDate()
            
            let emailTitle = "문의 \(today.0).\(today.1).\(today.2)"
            let messageBody =
            """
            OS Version: \(UIDevice.current.systemVersion)
            피드백 내용을 작성해주세요.
            """
            
            let toRecipents = ["codingjoa20@gmail.com"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.setToRecipients(toRecipents)
            
            present(mc, animated: true, completion: nil)
        }
    }
    
    private func showEmailAlert() {
        let message =
        """
        아이폰 이메일 설정을 확인하고 다시 시도해주세요.
        
        이메일 설정이 불가하신 경우, codingjoa20@gmail.com으로 문의주시기 바랍니다.
        """
        let sendMailErrorAlert = UIAlertController(title: "문의 작성 실패", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default)
        sendMailErrorAlert.addAction(confirmAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
}

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    @objc(mailComposeController:didFinishWithResult:error:)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,error: Error?) {
            controller.dismiss(animated: true)
    }
}
