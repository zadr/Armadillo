#if os(Linux) || os(FreeBSD)
import Glibc

Armadillo<POSIXUserDefaults>().run(POSIXArgumentParser())
#else
import Foundation

Armadillo<UserDefaults>().run(UserDefaults.standard)
#endif
