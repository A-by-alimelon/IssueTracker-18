//
//  NewIssueViewController.swift
//  IssueTracker
//
//  Created by A on 2020/11/10.
//

import UIKit

class NewIssueViewController: UIViewController {
    
    // MARK: - @IBOutlet Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var addNewIssueButton: UIButton!
    
    // MARK: - @IBAction
    @IBAction func toucedCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        addNewIssueButton.addTarget(self, action: #selector(postNewIssue), for: .touchUpInside)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Methods
    @objc private func postNewIssue() {
        
    }

}

extension NewIssueViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentTextView.text = ""
        contentTextView.textColor = UIColor.black
    }
}
