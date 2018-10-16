//
//  CountriesVC.swift
//  FirebaseDemo
//
//  Created by Ahmed Osama on 10/15/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import Kingfisher

class CountriesVC: UIViewController {
    
    // MARK: - Properties
    
    var handle: AuthStateDidChangeListenerHandle?
    var allCountries: JSON?
    
    // MARK: - Outlets
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        loadCountries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeListener()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch {
            debugPrint("Failed to logout")
        }
    }
    
    // MARK: - Helpers
    
    func setupListener() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let activeUser = user {
                self.username.text = activeUser.email
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func removeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func loadCountries() {
        Alamofire.request(API.countriesEndPoint).responseJSON { (response) in
            if let json = response.result.value {
                self.allCountries = JSON(json)
                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - UITableView Delegate & UITableView DataSource

extension CountriesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCountries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = allCountries?[indexPath.row]["name"].string!
        let code = allCountries?[indexPath.row]["alpha2Code"].string
        let imgUrl = URL(string: API.countryFlagImageURL(code: code!))
        cell.imageView?.kf.setImage(with: imgUrl, placeholder: UIImage(named: "logo")!, options: nil, progressBlock: nil) { (image, error, cache, url) in
            if image != nil {
                DispatchQueue.main.async {
                    cell.contentView.setNeedsLayout()
                }
            }
        }
        return cell
    }
}
