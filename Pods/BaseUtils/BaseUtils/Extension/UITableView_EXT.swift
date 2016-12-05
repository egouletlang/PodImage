//
//  UITableView_EXT.swift
//  Bankroll
//
//  Created by Etienne Goulet-Lang on 5/31/16.
//  Copyright © 2016 Etienne Goulet-Lang. All rights reserved.
//

import Foundation
import UIKit

public extension UITableView {
    
    /// Returns whether NSIndexPath is out of bounds in the current table view
    /// Can be used as safe guard before update/delete operations in the table view to avoid crashes
    public func isIndexPathValid(_ index: IndexPath) -> Bool {
        return ((index as NSIndexPath).section <= self.numberOfSections) && ((index as NSIndexPath).row <= self.numberOfRows(inSection: (index as NSIndexPath).section))
    }
    
}
