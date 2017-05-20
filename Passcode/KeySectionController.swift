//
//  KeySectionController.swift
//  Passcode
//
//  Created by CruzDiary on 20/05/2017.
//  Copyright © 2017 Cruz. All rights reserved.
//

import UIKit

import IGListKit

class Key: ListDiffable {
  var key: String
  init(key: String) {
    self.key = key
  }
  
  func diffIdentifier() -> NSObjectProtocol {
    return key as NSObjectProtocol
  }
  
  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    if self === object {
      return true
    }
    
    if let key = object as? Key {
      return self.key == key.key
    }
    
    return false
  }
}

class KeySectionController: ListSectionController {
  var key: Key?
  override func sizeForItem(at index: Int) -> CGSize {
    guard let context = collectionContext else { return .zero }
    return CGSize(width: context.containerSize.width/3, height: context.containerSize.width/4)
  }
  
  override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = collectionContext?.dequeueReusableCell(withNibName: KeyCell.nibName, bundle: nil, for: self, at: index)  as? KeyCell else {
      fatalError()
    }
    cell.keyLabel.text = key?.key
    return cell
  }
  
  override func didUpdate(to object: Any) {
    key = object as? Key
  }
}

