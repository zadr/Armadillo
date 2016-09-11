#if os(Linux) || os(FreeBSD)
import Glibc

Program<POSIXUserDefaults>().run(POSIXArgumentParser())
#else
import Foundation

Program<NSUserDefaults>().run(NSUserDefaults.standardUserDefaults())
#endif
