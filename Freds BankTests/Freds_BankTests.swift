//
//  Freds_BankTests.swift
//  Freds BankTests
//
//  Created by Jason Jobe on 4/28/20.
//  Copyright © 2020 Jason Jobe. All rights reserved.
//

import XCTest
import SnapshotTesting

@testable import Freds_Bank
@testable import SQiftViewModel

class Freds_BankTests: XCTestCase {

    var viewModel: AppViewModel!
    var storyboard: UIStoryboard!
    
    override func setUpWithError() throws {
//        record = true
        viewModel = try! AppViewModel(storageLocation: .onDisk("/Users/jason/bank_test.db"))
        let mb = Bundle(for: AppDelegate.self)
        storyboard = UIStoryboard(name: "Main", bundle: mb)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppDelegate() {
        let appDelegate = AppDelegate()
        appDelegate.modelWillCommit(appDelegate.baseViewModel)
    }
    
    func testViewModel() throws {
        try viewModel.clear(env: "demo")
        try viewModel.clear(log: "demo")
        viewModel.set(env: "search", to: "keyw")
        _ = viewModel.sql_predicate(field: "name", search: "search")
        
        let path = Bundle(for: AppDelegate.self).path(forResource: "branches", ofType: "json")
        try viewModel.load(path, into: "_branches")
        let url = URL(fileURLWithPath: path!)
        viewModel.load(url: url, into: "_branches")
    }
    
    func testMapController() throws {
        let map = storyboard.instantiateViewController(identifier: "MapController") as! MapViewController
        checkViewController(map) {
            if let pin = $0.items.first {
                $0.mapView?.selectAnnotation(pin, animated: false)
            }
            $0.selectMapItem(self)
            
            assertSnapshot(matching: $0, as: .dump)
            assertSnapshot(matching: $0, as: .image(on: .iPhoneSe))

            $0.mapView($0.mapView!, regionDidChangeAnimated: false)
            $0.saveSelectedLocation()
            let seg = UIStoryboardSegue(identifier: "jump", source: $0, destination: $0)
            $0.prepare(for: seg, sender: nil)
        }
    }

    func testTableController() throws {
        let vc = storyboard.instantiateViewController(identifier: "TableController") as! TableViewController
        checkViewController(vc) {
            $0.tableView($0.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            assertSnapshot(matching: $0, as: .image(on: .iPhoneSe))
            assertSnapshot(matching: $0, as: .recursiveDescription(on: .iPhoneSe))
            let seg = UIStoryboardSegue(identifier: "jump", source: $0, destination: $0)
            $0.prepare(for: seg, sender: nil)
        }
    }

    func testDetailController() throws {
        let vc = storyboard.instantiateViewController(identifier: "DetailController") as! DetailViewController
        vc.modelId = "locations/selected.branch"
        viewModel.set(env: "selected.branch", to: 1)
            checkViewController(vc) {
            assertSnapshot(matching: $0, as: .image(on: .iPhoneSe))
            assertSnapshot(matching: $0, as: .recursiveDescription(on: .iPhoneSe))
        }
    }

    func testSignaling() throws {
        viewModel.watchingForSignals = true
        viewModel.set(env: "signal", to: "Sender is \(#function)")
        sleep(1)
        viewModel.watchingForSignals = false
    }
    
    func checkViewController<VC: UIViewController>(_ vc: VC, f: ((VC) -> Void)? = nil) {
        _ = vc.view // force loading of the view
        vc.viewWillAppear(false)
        vc.refresh(from: viewModel)
        f?(vc)
        vc.viewWillDisappear(false)
        
    }

}
