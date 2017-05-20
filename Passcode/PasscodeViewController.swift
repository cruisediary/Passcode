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
    pastelView.animationDuration = 3.0
    pastelView.startAnimation()
    // Do any additional setup after loading the view, typically from a nib.
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
      .subscribe { [weak self](event) in
        guard let s = self, let message = event.element else { return }
        s.showMessage(message, type: .info)
      }.disposed(by: disposeBag)
    
    reactor.state
      .map { $0.keys.map { Key(key: $0) } }
      .bind(to: adapter.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    reactor.state
      .map { $0.validation }
      .filter { $0 != .normal }
      .do(onNext: { [weak self](validation) in
        guard let s = self else { return }
        switch validation {
        case .valid:
          s.showMessage("Correct!!! 😜", type: .success)
        case .invalid:
          s.showMessage("InCorrect!!! 😥", type: .error)
        default: break
        }
      })
      .delay(1.0, scheduler: MainScheduler.instance)
      .subscribe { [weak self](event) in
        guard let s = self else { return }
        s.reactor?.action.onNext(PasscodeViewReactor.Action.generate)
      }.disposed(by: disposeBag)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

extension Reactive where Base: ListAdapter {
  func items<DataSource: RxListAdapterDataSource & ListAdapterDataSource, O: ObservableType>(dataSource: DataSource)
    -> (_ source: O)
    -> Disposable where DataSource.Element == O.E {
      
      return { source in
        let subscription = source
          .subscribe { dataSource.listAdapter(self.base, observedEvent: $0) }
        
        return Disposables.create {
          subscription.dispose()
        }
      }
  }
  
  func setDataSource<DataSource: RxListAdapterDataSource & ListAdapterDataSource>(_ dataSource: DataSource) -> Disposable {
    base.dataSource = dataSource
    return Disposables.create()
  }
}
