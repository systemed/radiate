package radiate {
	import flash.external.ExternalInterface;

	public class console {
		public static function log(...args):void {
			args.unshift("console.log");
			ExternalInterface.call.apply(null,args);
		}
	}
}
