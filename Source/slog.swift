
import UIKit

func slog(_ items: Any..., separator: String = " ", terminator: String = "\n", forcePublic: Bool = false) {
	
	if Spawn.logPublic || forcePublic == true {
		
		print(items, separator: separator, terminator: terminator)
	}
	
	
}
