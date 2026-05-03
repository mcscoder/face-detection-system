import 'api_transport.dart';
import 'live_api_transport_stub.dart'
    if (dart.library.io) 'live_api_transport_io.dart';

ApiTransport createLiveApiTransport(Uri baseUrl) {
  return createPlatformLiveApiTransport(baseUrl);
}
