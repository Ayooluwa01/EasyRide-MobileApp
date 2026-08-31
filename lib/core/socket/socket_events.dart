abstract class SocketEvents {
  // Client → Server
  static const String rideJoin = 'ride:join';
  static const String driverLocation = 'driver:location';

  // Server → Client

  static const String rideNew = 'ride:new';
  static const String rideMatched = 'ride:matched';
  static const String rideUnavailable = 'ride:unavailable';
  static const String rideDriverArrived = 'ride:driver-arrived';
  static const String rideStarted = 'ride:started';
  static const String rideCompleted = 'ride:completed';
  static const String rideCancelled = 'ride:cancelled';
  static const String rideDestinationReached = 'ride:destination-reached';
  static const String nearbyDrivers = 'nearby:drivers';
  static const String driverOffers = 'ride:offers';

  // Chat
  static const String messageNew = 'message:new';
}
