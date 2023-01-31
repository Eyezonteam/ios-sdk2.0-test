//
//  ViewController.swift
//  EyezonSDK-Test
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import UIKit
import EyezonSDK_2_0

var apnToken = ""
var bundleID = ""

class ViewController: UIViewController {
    
    private enum Constants {
        static let EYEZON_WIDGET_URL = "https://storage.googleapis.com/eyezonfortest/widget_2.0/sdkEnabled.html?eyezon"
        
        static let EYEZON_BUSINESS_ID = "23"
        static let EYEZON_BUTTON_ID = "13"
    }
    
    private var predefinedData: EyezonSDKData {
        EyezonSDKData(
            businessId: Constants.EYEZON_BUSINESS_ID,
            buttonId: Constants.EYEZON_BUTTON_ID,
            widgetUrl: Constants.EYEZON_WIDGET_URL
        )
    }
    
    private var servers: [ServerArea] {
        [.prod, .sandbox]
    }
    private let selectedServer: ServerArea = .sandbox
    
    private lazy var eyezonButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 40)))
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(openEyezon), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SDK TEST", for: .normal)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 40)))
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(eyezonButton)
        view.addSubview(logoutButton)
        let constraints = [
            eyezonButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eyezonButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            eyezonButton.widthAnchor.constraint(equalToConstant: 100),
            eyezonButton.heightAnchor.constraint(equalToConstant: 40),
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: eyezonButton.bottomAnchor, constant: 15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc
    private func openEyezon() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        apnToken = delegate?.pushToken ?? "Device token is empty"
        
        bundleID = Bundle.main.bundleIdentifier ?? "BundleID is empty"
        
        Eyezon.instance.initSdk(area: selectedServer) { [weak self, predefinedData] in
            guard let strongSelf = self else { return }
            let eyezonWebViewController = Eyezon.instance.openButton(data: predefinedData, broadcastReceiver: strongSelf)
            strongSelf.present(eyezonWebViewController, animated: true, completion: nil)
        }
    }
    
    @objc
    private func logout() {
        Eyezon.instance.logout { logout, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            print("Success logout")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension ViewController: EyezonBroadcastReceiver {
    func onConsoleEvent(eventName: String, event: [String: Any]) {
        print(#function, " \(eventName)")
    }
}
