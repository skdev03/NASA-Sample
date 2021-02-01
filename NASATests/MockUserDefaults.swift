import Foundation

class MockUserDefaults: UserDefaults {

    convenience init() {
        self.init(suiteName: "___MockSpokTestingUserDefaults___")!
    }

    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }
}

