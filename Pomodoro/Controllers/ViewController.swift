//
//  ViewController.swift
//  Pomodoro
//
//  Created by juyeong koh on 2022/10/21.
//

import UIKit


enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    // 타이머에 저장된 시간을 초로 저장하는 프로퍼티 (초기화)
    var duration = 60
    // 타이머의 상태를 가지고 있는 프로퍼티
    var timerStatus: TimerStatus = .end
    // ✨ GCD API
    var timer: DispatchSourceTimer?
    
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureToggleButton()
    }
    
    
    
    
    // MARK: - methods

    func setTimerInfoViewVisible(isHidden: Bool) {
        timerLabel.isHidden = isHidden
        progressView.isHidden = isHidden
    }
    
    // 상태에 따라 버튼 상태 변경
    func configureToggleButton() {
        toggleButton.setTitle("시작", for: .normal)
        toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now(), repeating: 1)
            timer?.setEventHandler(handler: { [weak self] in
                self?.currentSeconds -= 1
                debugPrint(self?.currentSeconds)
                
                if self?.currentSeconds ?? 0 <= 0 {
                    // 타이머가 종료
                    self?.stopTimer()
                }
            })
            timer?.resume()
        }
    }
    
    // 0보다 작거나 같을 때, 취소버튼을 눌렀을 때 타이머가 종료되게 구현
    func stopTimer() {
        if timerStatus == .pause {
            timer?.resume()
        }
        
        timerStatus = .end
        cancelButton.isEnabled = false
        setTimerInfoViewVisible(isHidden: true)
        datePicker.isHidden = false
        toggleButton.isSelected = false
        
        timer?.cancel()
        timer = nil
    }
    
    
    // MARK: - IBAction

    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        
        switch timerStatus {
            
        case .start, .pause:
            stopTimer()
            
        default:
            break

        }
        
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        duration = Int(datePicker.countDownDuration)
        
        switch timerStatus {
            
        case .start:
            timerStatus = .pause
            toggleButton.isSelected = false
            timer?.suspend()
            
        case .end:
            currentSeconds = duration
            timerStatus = .start
            setTimerInfoViewVisible(isHidden: false)
            datePicker.isHidden = true
            toggleButton.isSelected = true
            cancelButton.isEnabled = true
            startTimer()
            
        case .pause:
            timerStatus = .start
            toggleButton.isSelected = true
            timer?.resume()

        }
    }
}

