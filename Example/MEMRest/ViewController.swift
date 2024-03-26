//
//  ViewController.swift
//  MEMRest
//
//  Created by Millerscript on 03/26/2024.
//  Copyright (c) 2024 Millerscript. All rights reserved.
//

import UIKit
import MEMRest
import MEMBase
import Combine

class ViewController: MEMBaseViewController {

    struct Constants {
       static var title = "MCRest Testing Items"
       static var statusTitle = "Status: "
       static var cellID = "RestCell"
    }
   
    let titleLbl: UILabel = {
       let style = MRFontStylesManager()
       
       let label = UILabel().newSet()
       label.textColor = .darkGray
       label.font = style.bold(size: 20)
       label.numberOfLines = 1
       label.textAlignment = .center
       label.text = Constants.title
       return label
    }()
   
    let statusLbl: UILabel = {
       let style = MRFontStylesManager()
       
       let label = UILabel().newSet()
       label.textColor = .darkGray
       label.font = style.bold(size: 20)
       label.numberOfLines = 0
       label.textAlignment = .left
       label.text = Constants.statusTitle
       return label
    }()
   
    let statusTextLbl: UILabel = {
       let style = MRFontStylesManager()
       
       let label = UILabel().newSet()
       label.textColor = .darkGray
       label.font = style.medium(size: 18)
       label.numberOfLines = 0
       label.textAlignment = .left
       label.text = ""
       return label
    }()

    var buttonList: UICollectionView?

    private var viewModel = RequestExampleViewModel()
    var anyCancellable: [AnyCancellable] = []

    required init(data: [String : Any]) {
       super.init(data: data)
    }

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
       self.view.backgroundColor = .white
       
       setTitle()
       setListView()
       setStatusLbl()
       subscriptions()
       
       viewModel.getList()
    }
       
    private func setTitle() {
       self.view.addSubview(titleLbl)
       titleLbl.hook(.top, to: .top, of: self.view, valueInset: 60)
       titleLbl.hookParentView(toSafeArea: .left)
       titleLbl.hookParentView(toSafeArea: .right)
    }

    private func setStatusLbl() {
       self.view.addSubview(statusLbl)
       self.view.addSubview(statusTextLbl)
       statusLbl.hook(.top, to: .bottom, of: buttonList!, valueInset: 20)
       statusLbl.hook(.left, to: .left, of: self.view, valueInset: 10)
       
       statusTextLbl.hook(.top, to: .bottom, of: buttonList!, valueInset: 20)
       statusTextLbl.hook(.left, to: .right, of: statusLbl, valueInset: 6)
       statusTextLbl.hook(.right, to: .right, of: self.view, valueInset: 10)
    }
       
    private func setListView() {
       
       let layout = UICollectionViewFlowLayout()
       layout.sectionInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
       layout.itemSize = CGSize(width: 80, height: 40)
       layout.scrollDirection = .horizontal
      
       buttonList = UICollectionView(frame: self.view.frame, collectionViewLayout: layout).newSet()
       
       buttonList?.register(RestCell.self, forCellWithReuseIdentifier: Constants.cellID)
       buttonList?.translatesAutoresizingMaskIntoConstraints = false
       buttonList?.backgroundColor = .white

       buttonList?.delegate = self
       buttonList?.dataSource = self
       
       self.view.addSubview(buttonList!)
       
       buttonList?.hook(.top, to: .bottom, of: titleLbl)
       buttonList?.hook(.left, to: .left, of: self.view)
       buttonList?.hook(.right, to: .right, of: self.view)
       buttonList?.setDimension(dimension: .height, value: 60)
    }
       
    private func getUserInformation() {
       Task(priority: .background){
           await viewModel.getUserInformationSuccess()
       }
    }

    private func getUserInformationTO() {
       Task(priority: .background) {
           await viewModel.getUserInformationTimeout()
       }
    }

    private func getFailInformation() {
       Task(priority: .background) {
           await viewModel.getUserInformationFail()
       }
    }
       
}

extension ViewController {
   func subscriptions() {
       buttonListSubscription()
       getUserInformationSubscription()
       getUserInformationTOSubscription()
       getUserFailInformation()
   }
   
   private func buttonListSubscription() {
       viewModel.buttonSuccessSubject.sink { _ in
            print("Some error")
        } receiveValue: { _ in
            self.buttonList?.reloadData()
        }.store(in: &anyCancellable)
   }
   
   private func getUserInformationSubscription() {
       viewModel.userSuccessSubject.sink { _ in
           print("Some error")
       } receiveValue: { data in
           DispatchQueue.main.async {
               self.statusTextLbl.text = "Success, with data \(data)"
           }
       }.store(in: &anyCancellable)
   }
   
   private func getUserInformationTOSubscription() {
       viewModel.userTOSuccessSubject.sink { error in
           DispatchQueue.main.async {
               self.statusTextLbl.text = "TimeOut, with data \(error)"
           }
       } receiveValue: { data in
          print("Nothing")
       }.store(in: &anyCancellable)
   }
   
   private func getUserFailInformation() {
       viewModel.userFailSuccessSubject.sink { _ in
           print("Some error in Fail method")
       } receiveValue: { data in
           print(data)
       }.store(in: &anyCancellable)

   }
   
   private func performAction(action: ButtonType) {
       switch action {
       case .Success:
           getUserInformation()
       case .Fail:
           getFailInformation()
       case .Timeout:
           getUserInformationTO()
       case .Idle:
           print("This action is missing")
       }
   }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   
   func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return viewModel.btnList.count
   }
   
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let button = viewModel.btnList[indexPath.item]
       performAction(action: button.type)
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let data = viewModel.btnList[indexPath.item]
       
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? RestCell else { return UICollectionViewCell() }
       cell.setButton(title: data.title)
       return cell
   }
}

