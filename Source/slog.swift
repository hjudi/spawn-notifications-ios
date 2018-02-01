
import UIKit

func slog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
	
	if Spawn.logPublic {
		
		print(items, separator: separator, terminator: terminator)
	}
	
	
}
