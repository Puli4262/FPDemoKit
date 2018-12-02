//
//  DateOfBirthViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 27/11/18.
//

import UIKit

class DateOfBirthViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    var dateOfBirthDelegate:DateOfBirthDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = UIDatePickerMode.date
        //datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
    }
    
    @IBAction func handleSelectedDate(_ sender: Any) {
        
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "YYYY"
        dateOfBirthDelegate?.selectedDateOfBirth(day: dayFormatter.string(from: datePicker.date), month: monthFormatter.string(from: datePicker.date), year: yearFormatter.string(from: datePicker.date))
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch: UITouch? = touches.first
        
        if touch?.view != self.datePicker  {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

protocol DateOfBirthDelegate {
    
    func selectedDateOfBirth(day:String,month:String,year:String)
}

