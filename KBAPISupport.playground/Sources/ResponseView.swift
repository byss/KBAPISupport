import AppKit
import Cocoa

public final class ResponseView: NSView {
	public enum State {
		case ready;
		case loading;
		case success;
		case failure;
		
		fileprivate var imageName: NSImage.Name {
			switch (self) {
			case .ready:
				return NSImage.statusNoneName;
			case .loading:
				return NSImage.statusPartiallyAvailableName;
			case .success:
				return NSImage.statusAvailableName;
			case .failure:
				return NSImage.statusUnavailableName;
			}
		}
	}
	
	public var state: State {
		didSet {
			self.resultImage.image = NSImage (named: state.imageName);
		}
	}
	private unowned let resultImage: NSImageView;
	
	public override init (frame: NSRect) {
		self.state = .ready;
		let resultImage = NSImageView (frame: NSRect (origin: .zero, size: frame.size));
		resultImage.autoresizingMask = [.width, .height];
		resultImage.image = NSImage (named: self.state.imageName);
		self.resultImage = resultImage;
		super.init (frame: frame);
		self.addSubview (resultImage);
	}
	
	public required init (coder aDecoder: NSCoder) {
		fatalError ();
	}
}
