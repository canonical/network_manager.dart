import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';
import 'package:test/test.dart';

class MockNetworkManagerObject extends DBusObject {
  MockNetworkManagerObject(DBusObjectPath path) : super(path);
}

class MockNetworkManagerManagerObject extends MockNetworkManagerObject {
  final MockNetworkManagerServer server;

  final int connectivity;
  final bool connectivityCheckAvailable;
  final bool connectivityCheckEnabled;
  final String connectivityCheckUri;
  final int metered;
  final bool networkingEnabled;
  final String primaryConnectionType = ''; // FIXME: pull from PrimaryConnection
  final bool startup;
  final int state;
  final String version;
  final bool wirelessEnabled;
  final bool wirelessHardwareEnabled;

  MockNetworkManagerManagerObject(this.server,
      {this.connectivity = 0,
      this.connectivityCheckAvailable = false,
      this.connectivityCheckEnabled = false,
      this.connectivityCheckUri = '',
      this.metered = 0,
      this.networkingEnabled = true,
      this.startup = true,
      this.state = 0,
      this.version = '',
      this.wirelessEnabled = true,
      this.wirelessHardwareEnabled = true})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager': {
          'AllDevices': DBusArray(DBusSignature('o'),
              server.allDevices.map((device) => device.path)),
          'Connectivity': DBusUint32(connectivity),
          'ConnectivityCheckAvailable': DBusBoolean(connectivityCheckAvailable),
          'ConnectivityCheckEnabled': DBusBoolean(connectivityCheckEnabled),
          'ConnectivityCheckUri': DBusString(connectivityCheckUri),
          'Devices': DBusArray(
              DBusSignature('o'), server.devices.map((device) => device.path)),
          'Metered': DBusUint32(metered),
          'NetworkingEnabled': DBusBoolean(networkingEnabled),
          'PrimaryConnectionType': DBusString(primaryConnectionType),
          'Startup': DBusBoolean(startup),
          'State': DBusUint32(state),
          'Version': DBusString(version),
          'WirelessEnabled': DBusBoolean(wirelessEnabled),
          'WirelessHardwareEnabled': DBusBoolean(wirelessHardwareEnabled),
        }
      };
}

class MockNetworkManagerDeviceObject extends MockNetworkManagerObject {
  final bool autoconnect;
  final int capabilities;
  final int deviceType;
  final String driver;
  final String driverVersion;
  final bool firmwareMissing;
  final String firmwareVersion;
  final String hwAddress;
  final String interface;
  final int interfaceFlags;
  final MockNetworkManagerIP4ConfigObject? ip4Config;
  final int ip4Connectivity;
  final MockNetworkManagerIP6ConfigObject? ip6Config;
  final int ip6Connectivity;
  final String ipInterface;
  final bool managed;
  final int metered;
  final int mtu;
  final bool nmPluginMissing;
  final String path_;
  final String physicalPortId;
  final bool real;
  final int state;
  final String udi;

  final bool isWireless;
  final List<MockNetworkManagerAccessPointObject> accessPoints;
  final MockNetworkManagerAccessPointObject? activeAccessPoint;
  final int bitrate;
  final int lastScan;
  final int wirelessMode;
  final String permHwAddress;
  final int wirelessCapabilities;

  MockNetworkManagerDeviceObject(int id,
      {this.autoconnect = false,
      this.capabilities = 0,
      this.deviceType = 0,
      this.driver = '',
      this.driverVersion = '',
      this.firmwareMissing = false,
      this.firmwareVersion = '',
      this.hwAddress = '',
      this.interface = '',
      this.interfaceFlags = 0,
      this.ip4Config,
      this.ip4Connectivity = 0,
      this.ip6Config,
      this.ip6Connectivity = 0,
      this.ipInterface = '',
      this.managed = false,
      this.metered = 0,
      this.mtu = 0,
      this.nmPluginMissing = false,
      this.path_ = '',
      this.physicalPortId = '',
      this.real = true,
      this.state = 0,
      this.udi = '',
      this.isWireless = false,
      this.accessPoints = const [],
      this.activeAccessPoint,
      this.bitrate = 0,
      this.lastScan = 0,
      this.wirelessMode = 0,
      this.permHwAddress = '',
      this.wirelessCapabilities = 0})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/Devices/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties {
    var interfacesAndProperties_ = {
      'org.freedesktop.NetworkManager.Device': {
        'Autoconnect': DBusBoolean(autoconnect),
        'Capabilities': DBusUint32(capabilities),
        'DeviceType': DBusUint32(deviceType),
        'Driver': DBusString(driver),
        'DriverVersion': DBusString(driverVersion),
        'FirmwareMissing': DBusBoolean(firmwareMissing),
        'FirmwareVersion': DBusString(firmwareVersion),
        'HwAddress': DBusString(hwAddress),
        'Interface': DBusString(interface),
        'InterfaceFlags': DBusUint32(interfaceFlags),
        'Ip4Config': ip4Config?.path ?? DBusObjectPath('/'),
        'Ip4Connectivity': DBusUint32(ip4Connectivity),
        'Ip6Config': ip6Config?.path ?? DBusObjectPath('/'),
        'Ip6Connectivity': DBusUint32(ip6Connectivity),
        'IpInterface': DBusString(ipInterface),
        'Managed': DBusBoolean(managed),
        'Metered': DBusUint32(metered),
        'Mtu': DBusUint32(mtu),
        'NmPluginMissing': DBusBoolean(nmPluginMissing),
        'Path': DBusString(path_),
        'PhysicalPortId': DBusString(physicalPortId),
        'Real': DBusBoolean(real),
        'State': DBusUint32(state),
        'Udi': DBusString(udi)
      }
    };
    if (isWireless) {
      interfacesAndProperties_[
          'org.freedesktop.NetworkManager.Device.Wireless'] = {
        'AccessPoints': DBusArray(DBusSignature('o'),
            accessPoints.map((accessPoint) => accessPoint.path)),
        'ActiveAccessPoint': activeAccessPoint?.path ?? DBusObjectPath('/'),
        'Bitrate': DBusUint32(bitrate),
        'LastScan': DBusInt64(lastScan),
        'Mode': DBusUint32(wirelessMode),
        'PermHwAddress': DBusString(permHwAddress),
        'WirelessCapabilities': DBusUint32(wirelessCapabilities)
      };
    }

    return interfacesAndProperties_;
  }
}

class MockNetworkManagerAccessPointObject extends MockNetworkManagerObject {
  final int flags;
  final int frequency;
  final String hwAddress;
  final int lastSeen;
  final int maxBitrate;
  final int mode;
  final int rsnFlags;
  final List<int> ssid;
  final int strength;
  final int wpaFlags;

  MockNetworkManagerAccessPointObject(int id,
      {this.flags = 0,
      this.frequency = 0,
      this.hwAddress = '',
      this.lastSeen = 0,
      this.maxBitrate = 0,
      this.mode = 0,
      this.rsnFlags = 0,
      this.ssid = const [],
      this.strength = 0,
      this.wpaFlags = 0})
      : super(
            DBusObjectPath('/org/freedesktop/NetworkManager/AccessPoints/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.AccessPoint': {
          'Flags': DBusUint32(flags),
          'Frequency': DBusUint32(frequency),
          'HwAddress': DBusString(hwAddress),
          'LastSeen': DBusInt32(lastSeen),
          'MaxBitrate': DBusUint32(maxBitrate),
          'Mode': DBusUint32(mode),
          'RsnFlags': DBusUint32(rsnFlags),
          'Ssid': DBusArray(DBusSignature('y'), ssid.map((v) => DBusByte(v))),
          'Strength': DBusByte(strength),
          'WpaFlags': DBusUint32(wpaFlags)
        }
      };
}

class MockNetworkManagerIP4ConfigObject extends MockNetworkManagerObject {
  final List<Map<String, DBusValue>> addressData;
  final List<String> dnsOptions;
  final int dnsPriority;
  final List<String> domains;
  final String gateway;
  final List<Map<String, DBusValue>> nameserverData;
  final List<Map<String, DBusValue>> routeData;
  final List<String> searches;
  final List<String> winsServerData;

  MockNetworkManagerIP4ConfigObject(int id,
      {this.addressData = const [],
      this.dnsOptions = const [],
      this.dnsPriority = 0,
      this.domains = const [],
      this.gateway = '',
      this.nameserverData = const [],
      this.routeData = const [],
      this.searches = const [],
      this.winsServerData = const []})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/IP4Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.IP4Config': {
          'AddressData': DBusArray(
              DBusSignature('a{sv}'),
              addressData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'DnsOptions': DBusArray(DBusSignature('s'),
              dnsOptions.map((option) => DBusString(option))),
          'DnsPriority': DBusInt32(dnsPriority),
          'Domains': DBusArray(
              DBusSignature('s'), domains.map((domain) => DBusString(domain))),
          'Gateway': DBusString(gateway),
          'NameserverData': DBusArray(
              DBusSignature('a{sv}'),
              nameserverData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'RouteData': DBusArray(
              DBusSignature('a{sv}'),
              routeData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'Searches': DBusArray(
              DBusSignature('s'), searches.map((search) => DBusString(search))),
          'WinsServerData': DBusArray(DBusSignature('s'),
              winsServerData.map((server) => DBusString(server)))
        }
      };
}

class MockNetworkManagerIP6ConfigObject extends MockNetworkManagerObject {
  final List<Map<String, DBusValue>> addressData;
  final List<String> dnsOptions;
  final int dnsPriority;
  final List<String> domains;
  final String gateway;
  final List<Map<String, DBusValue>> nameserverData;
  final List<Map<String, DBusValue>> routeData;
  final List<String> searches;

  MockNetworkManagerIP6ConfigObject(int id,
      {this.addressData = const [],
      this.dnsOptions = const [],
      this.dnsPriority = 0,
      this.domains = const [],
      this.gateway = '',
      this.nameserverData = const [],
      this.routeData = const [],
      this.searches = const []})
      : super(DBusObjectPath('/org/freedesktop/NetworkManager/IP6Config/$id'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.freedesktop.NetworkManager.IP6Config': {
          'AddressData': DBusArray(
              DBusSignature('a{sv}'),
              addressData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'DnsOptions': DBusArray(DBusSignature('s'),
              dnsOptions.map((option) => DBusString(option))),
          'DnsPriority': DBusInt32(dnsPriority),
          'Domains': DBusArray(
              DBusSignature('s'), domains.map((domain) => DBusString(domain))),
          'Gateway': DBusString(gateway),
          'NameserverData': DBusArray(
              DBusSignature('a{sv}'),
              nameserverData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'RouteData': DBusArray(
              DBusSignature('a{sv}'),
              routeData.map((data) => DBusDict(
                  DBusSignature('s'),
                  DBusSignature('v'),
                  data.map((key, value) =>
                      MapEntry(DBusString(key), DBusVariant(value)))))),
          'Searches': DBusArray(
              DBusSignature('s'), searches.map((search) => DBusString(search)))
        }
      };
}

class MockNetworkManagerServer extends DBusClient {
  final DBusObject _root;
  late final MockNetworkManagerManagerObject _manager;
  var _nextIp4ConfigId = 1;
  var _nextIp6ConfigId = 1;
  var _nextAccessPointId = 1;
  var _nextDeviceId = 1;

  final allDevices = <MockNetworkManagerDeviceObject>[];
  final devices = <MockNetworkManagerDeviceObject>[];

  MockNetworkManagerServer(DBusAddress clientAddress,
      {int connectivity = 0,
      bool connectivityCheckAvailable = false,
      bool connectivityCheckEnabled = false,
      String connectivityCheckUri = '',
      bool startup = true,
      int state = 0,
      String version = ''})
      : _root = DBusObject(DBusObjectPath('/org/freedesktop'),
            isObjectManager: true),
        super(clientAddress) {
    _manager = MockNetworkManagerManagerObject(this,
        connectivity: connectivity,
        connectivityCheckAvailable: connectivityCheckAvailable,
        connectivityCheckEnabled: connectivityCheckEnabled,
        connectivityCheckUri: connectivityCheckUri,
        startup: startup,
        state: state,
        version: version);
  }

  Future<void> start() async {
    await requestName('org.freedesktop.NetworkManager');
    await registerObject(_root);
    await registerObject(_manager);
  }

  Future<MockNetworkManagerIP4ConfigObject> addIp4Config({
    List<Map<String, DBusValue>> addressData = const [],
    List<String> dnsOptions = const [],
    int dnsPriority = 0,
    List<String> domains = const [],
    String gateway = '',
    List<Map<String, DBusValue>> nameserverData = const [],
    List<Map<String, DBusValue>> routeData = const [],
    List<String> searches = const [],
    List<String> winsServerData = const [],
  }) async {
    var config = MockNetworkManagerIP4ConfigObject(_nextIp4ConfigId,
        addressData: addressData,
        dnsOptions: dnsOptions,
        dnsPriority: dnsPriority,
        domains: domains,
        gateway: gateway,
        nameserverData: nameserverData,
        routeData: routeData,
        searches: searches,
        winsServerData: winsServerData);
    _nextIp4ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerIP6ConfigObject> addIp6Config(
      {List<Map<String, DBusValue>> addressData = const [],
      List<String> dnsOptions = const [],
      int dnsPriority = 0,
      List<String> domains = const [],
      String gateway = '',
      List<Map<String, DBusValue>> nameserverData = const [],
      List<Map<String, DBusValue>> routeData = const [],
      List<String> searches = const []}) async {
    var config = MockNetworkManagerIP6ConfigObject(_nextIp6ConfigId,
        addressData: addressData,
        dnsOptions: dnsOptions,
        dnsPriority: dnsPriority,
        domains: domains,
        gateway: gateway,
        nameserverData: nameserverData,
        routeData: routeData,
        searches: searches);
    _nextIp6ConfigId++;
    await registerObject(config);
    return config;
  }

  Future<MockNetworkManagerAccessPointObject> addAccessPoint(
      {int flags = 0,
      int frequency = 0,
      String hwAddress = '',
      int lastSeen = 0,
      int maxBitrate = 0,
      int mode = 0,
      int rsnFlags = 0,
      List<int> ssid = const [],
      int strength = 0,
      int wpaFlags = 0}) async {
    var accessPoint = MockNetworkManagerAccessPointObject(_nextAccessPointId,
        flags: flags,
        frequency: frequency,
        hwAddress: hwAddress,
        lastSeen: lastSeen,
        maxBitrate: maxBitrate,
        mode: mode,
        rsnFlags: rsnFlags,
        ssid: ssid,
        strength: strength,
        wpaFlags: wpaFlags);
    _nextAccessPointId++;
    await registerObject(accessPoint);
    return accessPoint;
  }

  Future<MockNetworkManagerDeviceObject> addDevice({
    bool autoconnect = false,
    int capabilities = 0,
    int deviceType = 0,
    String driver = '',
    String driverVersion = '',
    String firmwareVersion = '',
    String hwAddress = '',
    String interface = '',
    int interfaceFlags = 0,
    MockNetworkManagerIP4ConfigObject? ip4Config,
    int ip4Connectivity = 0,
    MockNetworkManagerIP6ConfigObject? ip6Config,
    int ip6Connectivity = 0,
    String ipInterface = '',
    bool managed = false,
    int metered = 0,
    int mtu = 0,
    bool nmPluginMissing = false,
    String path = '',
    String physicalPortId = '',
    bool real = true,
    int state = 0,
    String udi = '',
    bool isWireless = false,
    List<MockNetworkManagerAccessPointObject> accessPoints = const [],
    MockNetworkManagerAccessPointObject? activeAccessPoint,
    int bitrate = 0,
    int lastScan = 0,
    int wirelessMode = 0,
    String permHwAddress = '',
    int wirelessCapabilities = 0,
  }) async {
    var device = MockNetworkManagerDeviceObject(_nextDeviceId,
        autoconnect: autoconnect,
        capabilities: capabilities,
        deviceType: deviceType,
        driver: driver,
        driverVersion: driverVersion,
        firmwareVersion: firmwareVersion,
        hwAddress: hwAddress,
        interface: interface,
        interfaceFlags: interfaceFlags,
        ip4Config: ip4Config,
        ip4Connectivity: ip4Connectivity,
        ip6Config: ip6Config,
        ip6Connectivity: ip6Connectivity,
        ipInterface: ipInterface,
        managed: managed,
        metered: metered,
        mtu: mtu,
        nmPluginMissing: nmPluginMissing,
        path_: path,
        physicalPortId: physicalPortId,
        real: real,
        state: state,
        udi: udi,
        isWireless: isWireless,
        accessPoints: accessPoints,
        activeAccessPoint: activeAccessPoint,
        bitrate: bitrate,
        lastScan: lastScan,
        wirelessMode: wirelessMode,
        permHwAddress: permHwAddress,
        wirelessCapabilities: wirelessCapabilities);
    _nextDeviceId++;
    await registerObject(device);
    allDevices.add(device);
    devices.add(device);
    return device;
  }
}

void main() {
  test('version', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress, version: '1.2.3');
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.version, equals('1.2.3'));

    await client.close();
  });

  test('connectivity', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress,
        connectivityCheckAvailable: true,
        connectivityCheckEnabled: true,
        connectivityCheckUri: 'http://example.com',
        connectivity: 4);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.connectivityCheckAvailable, isTrue);
    expect(client.connectivityCheckEnabled, isTrue);
    expect(client.connectivityCheckUri, equals('http://example.com'));
    expect(client.connectivity, NetworkManagerConnectivityState.full);

    await client.close();
  });

  test('no devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, isEmpty);

    await client.close();
  });

  test('devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:01');
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:02');
    await nm.addDevice(hwAddress: 'DE:71:CE:00:00:03');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(3));
    expect(client.devices[0].hwAddress, equals('DE:71:CE:00:00:01'));
    expect(client.devices[1].hwAddress, equals('DE:71:CE:00:00:02'));
    expect(client.devices[2].hwAddress, equals('DE:71:CE:00:00:03'));

    await client.close();
  });

  test('device properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    await nm.addDevice(
        autoconnect: true,
        capabilities: 0xf,
        deviceType: 1,
        driver: 'DRIVER',
        driverVersion: 'DRIVER-VERSION',
        firmwareVersion: 'FIRMWARE-VERSION',
        hwAddress: 'DE:71:CE:00:00:01',
        interface: 'INTERFACE',
        interfaceFlags: 0x10003,
        ip4Connectivity: 4,
        ip6Connectivity: 4,
        ipInterface: 'IP-INTERFACE',
        managed: true,
        metered: 1,
        mtu: 1500,
        nmPluginMissing: true,
        path: '/PATH',
        physicalPortId: 'PHYSICAL-PORT-ID',
        real: true,
        state: 100,
        udi: 'UDI');

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.autoconnect, isTrue);
    expect(
        device.capabilities,
        equals({
          NetworkManagerDeviceCapability.networkManagerSupported,
          NetworkManagerDeviceCapability.carrierDetect,
          NetworkManagerDeviceCapability.isSoftware,
          NetworkManagerDeviceCapability.singleRootIOVirtualization
        }));
    expect(device.deviceType, equals(NetworkManagerDeviceType.ethernet));
    expect(device.driver, equals('DRIVER'));
    expect(device.driverVersion, equals('DRIVER-VERSION'));
    expect(device.firmwareVersion, equals('FIRMWARE-VERSION'));
    expect(device.hwAddress, equals('DE:71:CE:00:00:01'));
    expect(device.interface, equals('INTERFACE'));
    expect(
        device.interfaceFlags,
        equals({
          NetworkManagerDeviceInterfaceFlag.up,
          NetworkManagerDeviceInterfaceFlag.lowerUp,
          NetworkManagerDeviceInterfaceFlag.carrier
        }));
    expect(
        device.ip4Connectivity, equals(NetworkManagerConnectivityState.full));
    expect(
        device.ip6Connectivity, equals(NetworkManagerConnectivityState.full));
    expect(device.ip4Config, isNull);
    expect(device.ip6Config, isNull);
    expect(device.ipInterface, equals('IP-INTERFACE'));
    expect(device.managed, isTrue);
    expect(device.metered, equals(NetworkManagerMetered.yes));
    expect(device.mtu, equals(1500));
    expect(device.nmPluginMissing, isTrue);
    expect(device.path, equals('/PATH'));
    expect(device.physicalPortId, equals('PHYSICAL-PORT-ID'));
    expect(device.real, isTrue);
    expect(device.state, equals(NetworkManagerDeviceState.activated));
    expect(device.udi, equals('UDI'));

    await client.close();
  });

  test('device ip config', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var ip4c = await nm.addIp4Config(
        addressData: [
          {'address': DBusString('192.168.0.2'), 'prefix': DBusUint32(16)},
          {'address': DBusString('10.0.0.2'), 'prefix': DBusUint32(8)}
        ],
        dnsOptions: ['option4a', 'option4b'],
        dnsPriority: 42,
        domains: ['domain4a', 'domain4b'],
        gateway: '192.168.0.1',
        nameserverData: [
          {'address': DBusString('8.8.8.8')},
          {'address': DBusString('8.8.4.4')}
        ],
        routeData: [
          {'dest': DBusString('192.168.0.0'), 'prefix': DBusUint32(16)},
          {'dest': DBusString('10.0.0.0'), 'prefix': DBusUint32(8)}
        ],
        searches: ['search4a', 'search4b'],
        winsServerData: ['wins1', 'wins2']);
    var ip6c = await nm.addIp6Config(
        addressData: [
          {
            'address': DBusString('2001:0db8:85a3:0000:0000:8a2e:0370:7334'),
            'prefix': DBusUint32(32)
          },
        ],
        dnsOptions: ['option6a', 'option6b'],
        dnsPriority: 128,
        domains: ['domain6a', 'domain6b'],
        gateway: '2001:0db8:85a3:0000:0000:8a2e:0370:1234',
        nameserverData: [
          {'address': DBusString('2001:4860:4860::8888')},
          {'address': DBusString('2001:4860:4860::8844')}
        ],
        routeData: [
          {
            'dest': DBusString('fe80::'),
            'prefix': DBusUint32(64),
            'metric': DBusUint32(600)
          }
        ],
        searches: ['search6a', 'search6b']);
    await nm.addDevice(ip4Config: ip4c, ip6Config: ip6c);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.ip4Config, isNotNull);
    var ip4Config = device.ip4Config!;
    expect(
        ip4Config.addressData,
        equals([
          {'address': '192.168.0.2', 'prefix': 16},
          {'address': '10.0.0.2', 'prefix': 8}
        ]));
    expect(ip4Config.dnsPriority, equals(42));
    expect(ip4Config.dnsOptions, equals(['option4a', 'option4b']));
    expect(ip4Config.domains, equals(['domain4a', 'domain4b']));
    expect(ip4Config.gateway, equals('192.168.0.1'));
    expect(
        ip4Config.nameserverData,
        equals([
          {'address': '8.8.8.8'},
          {'address': '8.8.4.4'}
        ]));
    expect(
        ip4Config.routeData,
        equals([
          {'dest': '192.168.0.0', 'prefix': 16},
          {'dest': '10.0.0.0', 'prefix': 8}
        ]));
    expect(ip4Config.searches, equals(['search4a', 'search4b']));
    expect(ip4Config.winsServerData, equals(['wins1', 'wins2']));
    expect(device.ip6Config, isNotNull);
    var ip6Config = device.ip6Config!;
    expect(
        ip6Config.addressData,
        equals([
          {'address': '2001:0db8:85a3:0000:0000:8a2e:0370:7334', 'prefix': 32},
        ]));
    expect(ip6Config.dnsPriority, equals(128));
    expect(ip6Config.dnsOptions, equals(['option6a', 'option6b']));
    expect(ip6Config.domains, equals(['domain6a', 'domain6b']));
    expect(
        ip6Config.gateway, equals('2001:0db8:85a3:0000:0000:8a2e:0370:1234'));
    expect(
        ip6Config.nameserverData,
        equals([
          {'address': '2001:4860:4860::8888'},
          {'address': '2001:4860:4860::8844'}
        ]));
    expect(
        ip6Config.routeData,
        equals([
          {'dest': 'fe80::', 'prefix': 64, 'metric': 600},
        ]));
    expect(ip6Config.searches, equals(['search6a', 'search6b']));

    await client.close();
  });

  test('wireless device', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var nm = MockNetworkManagerServer(clientAddress);
    await nm.start();
    var ap1 = await nm.addAccessPoint(
        flags: 0xf,
        frequency: 5745,
        hwAddress: 'AC:CE:55:00:00:01',
        lastSeen: 123456789,
        maxBitrate: 270000,
        mode: 2,
        rsnFlags: 0x188,
        ssid: [104, 101, 108, 108, 111],
        strength: 59,
        wpaFlags: 0x144);
    var ap2 = await nm.addAccessPoint(hwAddress: 'AC:CE:55:00:00:02');
    var ap3 = await nm.addAccessPoint(hwAddress: 'AC:CE:55:00:00:03');
    await nm.addDevice(
        isWireless: true,
        accessPoints: [ap1, ap2, ap3],
        activeAccessPoint: ap1,
        bitrate: 135000,
        lastScan: 123456789,
        wirelessMode: 2,
        permHwAddress: 'DE:71:CE:00:00:01',
        wirelessCapabilities: 0x1027);

    var client = NetworkManagerClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.wireless, isNotNull);
    expect(device.wireless.accessPoints, hasLength(3));
    expect(
        device.wireless.accessPoints[0].hwAddress, equals('AC:CE:55:00:00:01'));
    expect(
        device.wireless.accessPoints[1].hwAddress, equals('AC:CE:55:00:00:02'));
    expect(
        device.wireless.accessPoints[2].hwAddress, equals('AC:CE:55:00:00:03'));
    expect(device.wireless.activeAccessPoint, isNotNull);
    var ap = device.wireless.activeAccessPoint!;
    expect(
        ap.flags,
        equals({
          NetworkManagerWifiAcessPointFlag.privacy,
          NetworkManagerWifiAcessPointFlag.wps,
          NetworkManagerWifiAcessPointFlag.wpsPushButton,
          NetworkManagerWifiAcessPointFlag.wpsPin
        }));
    expect(ap.frequency, equals(5745));
    expect(ap.hwAddress, equals('AC:CE:55:00:00:01'));
    expect(ap.lastSeen, equals(123456789));
    expect(ap.maxBitrate, equals(270000));
    expect(ap.mode, equals(NetworkManagerWifiMode.infra));
    expect(
        ap.rsnFlags,
        equals({
          NetworkManagerWifiAcessPointSecurityFlag.pairCCMP,
          NetworkManagerWifiAcessPointSecurityFlag.groupCCMP,
          NetworkManagerWifiAcessPointSecurityFlag.keyManagementPSK
        }));
    expect(ap.ssid, equals([104, 101, 108, 108, 111]));
    expect(ap.strength, equals(59));
    expect(
        ap.wpaFlags,
        equals({
          NetworkManagerWifiAcessPointSecurityFlag.pairTKIP,
          NetworkManagerWifiAcessPointSecurityFlag.groupTKIP,
          NetworkManagerWifiAcessPointSecurityFlag.keyManagementPSK
        }));
    expect(device.wireless.bitrate, equals(135000));
    expect(device.wireless.lastScan, equals(123456789));
    expect(device.wireless.mode, equals(NetworkManagerWifiMode.infra));
    expect(device.wireless.permHwAddress, equals('DE:71:CE:00:00:01'));
    expect(
        device.wireless.wirelessCapabilities,
        equals({
          NetworkManagerDeviceWifiCapability.cipherWEP40,
          NetworkManagerDeviceWifiCapability.cipherWEP104,
          NetworkManagerDeviceWifiCapability.cipherTKIP,
          NetworkManagerDeviceWifiCapability.rsn,
          NetworkManagerDeviceWifiCapability.mesh
        }));

    await client.close();
  });
}
