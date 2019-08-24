//
//  ViewController.swift
//  Passcode
//
//  Created by CruzDiary on 18/05/2017.
//  Copyright © 2017 Cruz. All rights reserved.
//

import UIKit

import GSMessages
import IGListKit
import Pastel
import ReactorKit
import RxCocoa
import RxSwift

class PasscodeViewController: UIViewController, View {
    @IBOutlet weak var generateButton: UIButton!
  
    // IGListKit
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    @IBOutlet weak var collectionView: UICollectionView!
    private let dataSource = DataSource()

    @IBOutlet var passcodeViews: [UIView]!
    // Rx
    var disposeBag = DisposeBag()
  
    var keys: [String] = []
  
    @IBOutlet weak var pastelView: PastelView!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // ReactorKit
        self.reactor = PasscodeViewReactor()
    
        // IGListKit
        collectionView.collectionViewLayout = ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
        adapter.collectionView = collectionView
        adapter.collectionViewDelegate = self
    
        // RxIGListKit
        adapter.rx.setDataSource(dataSource)
            .disposed(by: disposeBag)
    
        // Pastel
        pastelView.setColors([#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1), #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)])
        pastelView.animationDuration = 2.0
        pastelView.startAnimation()
    
        // UI
        passcodeViews.forEach {
          $0.clipsToBounds = true
          $0.layer.cornerRadius = 10
          $0.layer.borderWidth = 1.0
          $0.layer.borderColor = UIColor.white.cgColor
          $0.backgroundColor = .clear
        }
    }
  
    func bind(reactor: PasscodeViewReactor) {
        // Action
        generateButton.rx.tap
            .map { Reactor.Action.generate }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        collectionView.rx
            .itemSelected
            .map { [weak self] in self?.adapter.object(atSection: $0.section) as? String }
            .map { Reactor.Action.typing(key: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state
            .map { $0.passcode }
            .distinctUntilChanged()
            .map { "😜 Password changed to \($0)" }
            .subscribe(onNext: { [weak self] message in
                self?.showMessage(message, type: .info)
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.keys.map { Key(key: $0) } }
            .bind(to: adapter.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.validation }
            .distinctUntilChanged()
            .filter { $0 != .normal }
            .do(onNext: { [weak self](validation) in
                guard let s = self else { return }
                switch validation {
                case .valid:
                    s.showMessage("Correct!!! 😜", type: .success)
                case .invalid:
                    s.showMessage("InCorrect!!! 😥", type: .error)
                default:
                    break
                }
            })
            .delay(2.0, scheduler: MainScheduler.instance)
            .map { _ in PasscodeViewReactor.Action.generate }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.input.count }
            .subscribe(onNext: { [weak self] count in
                guard let s = self else { return }
                for (idx, view) in s.passcodeViews.enumerated() {
                    view.backgroundColor = idx < count ? .white : .clear
                }
            })
            .disposed(by: disposeBag)
    }
  
    // RxIGListKit
    final class DataSource: NSObject, ListAdapterDataSource, RxListAdapterDataSource {
        typealias Element = [Key]
    
        var elements: Element = []
    
        func listAdapter(_ adapter: ListAdapter, observedEvent: Event<[Key]>) {
            if case .next(let keys) = observedEvent {
                elements = keys
                adapter.performUpdates(animated: true)
            }
        }
    
        func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
            return elements as [ListDiffable]
        }
    
        func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
            return KeySectionController()
        }
    
        func emptyView(for listAdapter: ListAdapter) -> UIView? {
            return nil
        }
    }
}

protocol RxListAdapterDataSource {
    associatedtype Element
    func listAdapter(_ adapter: ListAdapter, observedEvent: Event<Element>) -> Void
}

extension PasscodeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let object = adapter.object(atSection: indexPath.section) as? Key else { return }
        reactor?.action.onNext(PasscodeViewReactor.Action.typing(key: object.key))
    }
}
