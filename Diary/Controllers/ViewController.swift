//
//  ViewController.swift
//  Diary
//
//  Created by juyeong koh on 2022/10/19.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList: [Diary] = [] {
        didSet {
            // 다이어리 리스트 배열에 추가되거나 변경이 일어날 때마다 유저디폴스에 저장되게 됨
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        self.loadDiaryList()
    }

    // 다이어리 리스트 배열에 추가된 일기를 콜렉션뷰에 표시되도록 구현
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    
    // userDefaults에 저장된 값을 불러오는 메소드
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        
        // 일기를 불러올때 최신순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            // 내림차순
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    private func saveDiaryList() {
        
        // 일기들을 userDefaluts에 딕셔너리 형태로 저장
        let date = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
    }
    
    
    // dat 타입을 전달받으면 문자열로 만들어주는 메서드
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 m월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}



// MARK: - extension

// 콜렉션뷰에서 데이터소스는 콜렉션뷰로 보여주는 컨텐츠를 관리하는 객체
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    // 표시할 셀을 요청
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // deque를 사용해 커스텀뷰에서 사용했던 셀을 가져올 것이다.
        // DiaryCell로 다운캐스팅하여, 다운캐스팅에 실패하면 빈 콜렉션뷰셀이 반환되게 구현
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        
        // Cell에 일기의 제목과 날짜가 표시되도록 구현
        // indexPath.row값으로 배열에 저장되어있는 일기를 가져온다.
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        
        return cell
    }
}


// 콜렉션뷰의 레이아웃
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    // 셀의 사이즈를 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 너비값이 2, left right 간격 -20만큼, 높이 200
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}


extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        // 작성화면에서 일기가 등록될때마다 다이어리 리스트 배열에 추가 > 콜렉션뷰에 추가됨
        self.diaryList.append(diary)
        self.diaryList = self.diaryList.sorted(by: {
            // 내림차순
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}

