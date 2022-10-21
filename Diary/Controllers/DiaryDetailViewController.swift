//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by juyeong koh on 2022/10/19.
//

import UIKit


class DiaryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var starButton: UIBarButtonItem?
    
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
    }
    
    
    // MARK: - func
    
    // date 타입을 전달받으면 문자열로 만들어주는 메서드
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 m월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        
        self.starButton = UIBarButtonItem(
            image: nil,
            style: .plain,
            target: self,
            action: #selector(tapStarButton)
        )
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    
    @objc func tapStarButton() {
        
        // 즐겨찾기 토글기능
        guard let isStar = self.diary?.isStar else { return }
        guard let indexPath = self.indexPath else { return }
        
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                "indexPath": indexPath
            ],
            userInfo: nil
        )
        
    }
    
    
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.diary = diary
        self.configureView()
    }
    
    
    
    // MARK: - IBAction
    
    @IBAction func tapEditButton(_ sender: UIButton) {
        // 다이어리 작성 화면으로 푸쉬되도록
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        
        // 수정 버튼을 눌렀을 때 editDiary의 옵저버
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editDiaryNotification(_:)),
                                               name: NSNotification.Name("editDiary"),
                                               object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        NotificationCenter.default.post(name: NSNotification.Name("deleteDiary"),
                                        object: indexPath,
                                        userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // 관찰이 필요 없을때는 옵저버를 제거할 수 있ㅇㅁ
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
