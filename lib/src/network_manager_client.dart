import 'dart:async';

import 'package:dbus/dbus.dart';

enum ConnectivityState { unknown, none, portal, limited, full }

enum DeviceState {
  unknown,
  unmanaged,
  unavailable,
  disconnected,
  prepare,
  config,
  need_auth,
  ip_config,
  ip_check,
  secondaries,
  activated,
  deactivating,
  failed
}

enum DeviceType {
  unknown,
  ethernet,
  wifi,
  bluetooth,
  olpc_mesh,
  wimax,
  modem,
  infiniband,
  bond,
  vlan,
  adsl,
  bridge,
  generic,
  team,
  tun,
  ip_tunnel,
  macvlan,
  vxlan,
  veth,
  macsec,
  dummy,
  ppp,
  ovs_interface,
  ovs_port,
  ovs_bridge,
  wpan,
  _6lowpan,
  wireguard,
  wifi_p2p,
  vrf
}

class NetworkManagerSettings {
  final String settingsInterfaceName =
      'org.freedesktop.NetworkManager.Settings';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerSettings(this.client, this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[settingsInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  List<NetworkManagerSettingsConnection> get connections {
    var objectPaths = _object.getObjectPathArrayProperty(
        settingsInterfaceName, 'Connections');
    var connections = <NetworkManagerSettingsConnection>[];
    for (var objectPath in objectPaths) {
      var connection = client._getConnection(objectPath);
      if (connection != null) {
        connections.add(connection);
      }
    }
    return connections;
  }

  String get hostname =>
      _object.getStringProperty(settingsInterfaceName, 'Hostname');
  bool get canModify =>
      _object.getBooleanProperty(settingsInterfaceName, 'CanModify');
}

class NetworkManagerSettingsConnection {
  final String settingsConnectionInterfaceName =
      'org.freedesktop.NetworkManager.Settings.Connection';

  final _NetworkManagerObject _object;

  NetworkManagerSettingsConnection(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[settingsConnectionInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  bool get unsaved =>
      _object.getBooleanProperty(settingsConnectionInterfaceName, 'Unsaved');
  int get flags => _object.getUint32Property(
      settingsConnectionInterfaceName, 'Flags'); // FIXME: enum
  String get filename =>
      _object.getStringProperty(settingsConnectionInterfaceName, 'Filename');
}

class NetworkManagerDnsManager {
  final String dnsManagerInterfaceName =
      'org.freedesktop.NetworkManager.DnsManager';

  final _NetworkManagerObject _object;

  NetworkManagerDnsManager(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dnsManagerInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get mode => _object.getStringProperty(dnsManagerInterfaceName, 'Mode');
  String get rcManager =>
      _object.getStringProperty(dnsManagerInterfaceName, 'RcManager');
  List<Map<String, dynamic>> get configuration =>
      _object.getDataListProperty(dnsManagerInterfaceName, 'Configuration');
}

class NetworkManagerDevice {
  final String deviceInterfaceName = 'org.freedesktop.NetworkManager.Device';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  final NetworkManagerDeviceBluetooth bluetooth;
  final NetworkManagerDeviceGeneric generic;
  final NetworkManagerDeviceStatistics statistics;
  final NetworkManagerDeviceTun tun;
  final NetworkManagerDeviceVlan vlan;
  final NetworkManagerDeviceWired wired;
  final NetworkManagerDeviceWireless wireless;

  NetworkManagerDevice(this.client, this._object)
      : bluetooth = NetworkManagerDeviceBluetooth(_object),
        generic = NetworkManagerDeviceGeneric(_object),
        statistics = NetworkManagerDeviceStatistics(_object),
        tun = NetworkManagerDeviceTun(_object),
        vlan = NetworkManagerDeviceVlan(client, _object),
        wired = NetworkManagerDeviceWired(_object),
        wireless = NetworkManagerDeviceWireless(client, _object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[deviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get udi => _object.getStringProperty(deviceInterfaceName, 'Udi');
  String get path => _object.getStringProperty(deviceInterfaceName, 'Path');
  String get ipInterface =>
      _object.getStringProperty(deviceInterfaceName, 'IpInterface');
  String get driver => _object.getStringProperty(deviceInterfaceName, 'Driver');
  String get driverVersion =>
      _object.getStringProperty(deviceInterfaceName, 'DriverVersion');
  String get firmwareVersion =>
      _object.getStringProperty(deviceInterfaceName, 'FirmwareVersion');
  int get capabilities => _object.getUint32Property(
      deviceInterfaceName, 'Capabilities'); // FIXME: enum
  DeviceState get state {
    var value = _object.getUint32Property(deviceInterfaceName, 'State');
    if (value == 10) {
      return DeviceState.unmanaged;
    } else if (value == 20) {
      return DeviceState.unavailable;
    } else if (value == 30) {
      return DeviceState.disconnected;
    } else if (value == 40) {
      return DeviceState.prepare;
    } else if (value == 50) {
      return DeviceState.config;
    } else if (value == 60) {
      return DeviceState.need_auth;
    } else if (value == 70) {
      return DeviceState.ip_config;
    } else if (value == 80) {
      return DeviceState.ip_check;
    } else if (value == 90) {
      return DeviceState.secondaries;
    } else if (value == 100) {
      return DeviceState.activated;
    } else if (value == 110) {
      return DeviceState.deactivating;
    } else if (value == 120) {
      return DeviceState.failed;
    } else {
      return DeviceState.unknown;
    }
  }

  // FIXME: StateReason
  NetworkManagerActiveConnection get activeConnection {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'ActiveConnection');
    return client._getActiveConnection(objectPath);
  }

  NetworkManagerIP4Config get ip4Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'Ip4Config');
    return client._getIP4Config(objectPath);
  }

  NetworkManagerDHCP4Config get dhcp4Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'DHCP4Config');
    return client._getDHCP4Config(objectPath);
  }

  NetworkManagerIP6Config get ip6Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'Ip6Config');
    return client._getIP6Config(objectPath);
  }

  NetworkManagerDHCP6Config get dhcp6Config {
    var objectPath =
        _object.getObjectPathProperty(deviceInterfaceName, 'DHCP6Config');
    return client._getDHCP6Config(objectPath);
  }

  bool get managed =>
      _object.getBooleanProperty(deviceInterfaceName, 'Managed');
  bool get autoconnect =>
      _object.getBooleanProperty(deviceInterfaceName, 'Autoconnect');
  bool get firmwareMissing =>
      _object.getBooleanProperty(deviceInterfaceName, 'FirmwareMissing');
  bool get nmPluginMissing =>
      _object.getBooleanProperty(deviceInterfaceName, 'NmPluginMissing');
  DeviceType get deviceType {
    var value = _object.getUint32Property(deviceInterfaceName, 'DeviceType');
    if (value == 1) {
      return DeviceType.ethernet;
    } else if (value == 2) {
      return DeviceType.wifi;
    } else if (value == 5) {
      return DeviceType.bluetooth;
    } else if (value == 6) {
      return DeviceType.olpc_mesh;
    } else if (value == 7) {
      return DeviceType.wimax;
    } else if (value == 8) {
      return DeviceType.modem;
    } else if (value == 9) {
      return DeviceType.infiniband;
    } else if (value == 10) {
      return DeviceType.bond;
    } else if (value == 11) {
      return DeviceType.vlan;
    } else if (value == 12) {
      return DeviceType.adsl;
    } else if (value == 13) {
      return DeviceType.bridge;
    } else if (value == 14) {
      return DeviceType.generic;
    } else if (value == 15) {
      return DeviceType.team;
    } else if (value == 16) {
      return DeviceType.tun;
    } else if (value == 17) {
      return DeviceType.ip_tunnel;
    } else if (value == 18) {
      return DeviceType.macvlan;
    } else if (value == 19) {
      return DeviceType.vxlan;
    } else if (value == 20) {
      return DeviceType.veth;
    } else if (value == 21) {
      return DeviceType.macsec;
    } else if (value == 22) {
      return DeviceType.dummy;
    } else if (value == 23) {
      return DeviceType.ppp;
    } else if (value == 24) {
      return DeviceType.ovs_interface;
    } else if (value == 25) {
      return DeviceType.ovs_port;
    } else if (value == 26) {
      return DeviceType.ovs_bridge;
    } else if (value == 27) {
      return DeviceType.wpan;
    } else if (value == 28) {
      return DeviceType._6lowpan;
    } else if (value == 29) {
      return DeviceType.wireguard;
    } else if (value == 30) {
      return DeviceType.wifi_p2p;
    } else if (value == 31) {
      return DeviceType.vrf;
    } else {
      return DeviceType.unknown;
    }
  }

  // FIXME: AvailableConnections
  String get physicalPortId =>
      _object.getStringProperty(deviceInterfaceName, 'PhysicalPortId');
  int get mtu => _object.getUint32Property(deviceInterfaceName, 'Mtu');
  int get metered =>
      _object.getUint32Property(deviceInterfaceName, 'Metered'); // FIXME: enum
  // FIXME: LldpNeighbors
  bool get real => _object.getBooleanProperty(deviceInterfaceName, 'Real');
  // FIXME: Ip4Connectivity
  // FIXME: Ip6Connectivity
  int get interfaceFlags => _object.getUint32Property(
      deviceInterfaceName, 'InterfaceFlags'); // FIXME: enum
  String get hwAddress =>
      _object.getStringProperty(deviceInterfaceName, 'HwAddress');
}

class NetworkManagerDeviceBluetooth {
  final String bluetoothDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Bluetooth';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceBluetooth(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[bluetoothDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  int get btCapabilities =>
      _object.getUint32Property(bluetoothDeviceInterfaceName, 'BtCapabilities');
}

class NetworkManagerDeviceGeneric {
  final String genericDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Generic';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceGeneric(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[genericDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get typeDescription =>
      _object.getStringProperty(genericDeviceInterfaceName, 'TypeDescription');
}

class NetworkManagerDeviceStatistics {
  final String statisticsDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Statistics';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceStatistics(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[statisticsDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  int get refreshRateMs =>
      _object.getUint32Property(statisticsDeviceInterfaceName, 'RefreshRateMs');
  int get txBytes =>
      _object.getUint64Property(statisticsDeviceInterfaceName, 'TxBytes');
  int get rxBytes =>
      _object.getUint64Property(statisticsDeviceInterfaceName, 'RxBytes');
}

class NetworkManagerDeviceTun {
  final String tunDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Tun';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceTun(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[tunDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get permHwAddress =>
      _object.getStringProperty(tunDeviceInterfaceName, 'PermHwAddress');
  int get owner => _object.getInt64Property(tunDeviceInterfaceName, 'Owner');
  int get group => _object.getInt64Property(tunDeviceInterfaceName, 'Group');
  bool get noPi => _object.getBooleanProperty(tunDeviceInterfaceName, 'NoPi');
  bool get vnetHdr =>
      _object.getBooleanProperty(tunDeviceInterfaceName, 'VnetHdr');
  bool get multiQueue =>
      _object.getBooleanProperty(tunDeviceInterfaceName, 'MultiQueue');
}

class NetworkManagerDeviceVlan {
  final String vlanDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Vlan';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerDeviceVlan(this.client, this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[vlanDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  NetworkManagerDevice get parent {
    var objectPath =
        _object.getObjectPathProperty(vlanDeviceInterfaceName, 'Parent');
    return client._getDevice(objectPath);
  }

  int get vlanId =>
      _object.getUint32Property(vlanDeviceInterfaceName, 'VlanId');
}

class NetworkManagerDeviceWired {
  final String wiredDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Wired';

  final _NetworkManagerObject _object;

  NetworkManagerDeviceWired(this._object);

  String get permHwAddress =>
      _object.getStringProperty(wiredDeviceInterfaceName, 'PermHwAddress');
  int get speed => _object.getUint32Property(wiredDeviceInterfaceName, 'Speed');
  List<String> get s390Subchannels => _object.getStringArrayProperty(
      wiredDeviceInterfaceName, 'S390Subchannels');
}

class NetworkManagerDeviceWireless {
  final String wirelessDeviceInterfaceName =
      'org.freedesktop.NetworkManager.Device.Wireless';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerDeviceWireless(this.client, this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[wirelessDeviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get permHwAddress =>
      _object.getStringProperty(wirelessDeviceInterfaceName, 'PermHwAddress');
  int get mode => _object.getUint32Property(
      wirelessDeviceInterfaceName, 'Mode'); // FIXME: enum
  int get bitrate =>
      _object.getUint32Property(wirelessDeviceInterfaceName, 'Bitrate');
  List<NetworkManagerAccessPoint> get accessPoints {
    var objectPaths = _object.getObjectPathArrayProperty(
        wirelessDeviceInterfaceName, 'AccessPoints');
    var accessPoints = <NetworkManagerAccessPoint>[];
    for (var objectPath in objectPaths) {
      var accessPoint = client._getAccessPoint(objectPath);
      if (accessPoint != null) {
        accessPoints.add(accessPoint);
      }
    }

    return accessPoints;
  }

  NetworkManagerAccessPoint get activeAccessPoint {
    var objectPath = _object.getObjectPathProperty(
        wirelessDeviceInterfaceName, 'ActiveAccessPoint');
    return client._getAccessPoint(objectPath);
  }

  int get wirelessCapabilities => _object.getUint32Property(
      wirelessDeviceInterfaceName, 'WirelessCapabilities'); // FIXME: enum
  int get lastScan =>
      _object.getInt64Property(wirelessDeviceInterfaceName, 'LastScan');

  Future requestScan([Map<String, DBusValue> options = const {}]) async {
    var args = [
      DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          options.map(
              (name, value) => MapEntry(DBusString(name), DBusVariant(value))))
    ];
    var result = await _object.callMethod(
        wirelessDeviceInterfaceName, 'RequestScan', args);
    var values = result.returnValues;
    if (values.isNotEmpty) {
      throw 'RequestScan returned invalid result: ${values}';
    }
  }
}

class NetworkManagerActiveConnection {
  final String activeConnectionInterfaceName =
      'org.freedesktop.NetworkManager.Connection.Active';

  final NetworkManagerClient client;
  final _NetworkManagerObject _object;

  NetworkManagerActiveConnection(this.client, this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[activeConnectionInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  String get id =>
      _object.getStringProperty(activeConnectionInterfaceName, 'Id');
  String get uuid =>
      _object.getStringProperty(activeConnectionInterfaceName, 'Uuid');
  String get type =>
      _object.getStringProperty(activeConnectionInterfaceName, 'type');
  int get state => _object.getUint32Property(
      activeConnectionInterfaceName, 'State'); // FIXME: enum
  int get stateFlags => _object.getUint32Property(
      activeConnectionInterfaceName, 'StateFlags'); // FIXME: enum
  bool get default4 =>
      _object.getBooleanProperty(activeConnectionInterfaceName, 'Default');
  NetworkManagerIP4Config get ip4Config {
    var objectPath = _object.getObjectPathProperty(
        activeConnectionInterfaceName, 'Ip4Config');
    return client._getIP4Config(objectPath);
  }

  NetworkManagerDHCP4Config get dhcp4Config {
    var objectPath = _object.getObjectPathProperty(
        activeConnectionInterfaceName, 'DHCP4Config');
    return client._getDHCP4Config(objectPath);
  }

  bool get default6 =>
      _object.getBooleanProperty(activeConnectionInterfaceName, 'Default6');
  NetworkManagerIP6Config get ip6Config {
    var objectPath = _object.getObjectPathProperty(
        activeConnectionInterfaceName, 'Ip6Config');
    return client._getIP6Config(objectPath);
  }

  NetworkManagerDHCP6Config get dhcp6Config {
    var objectPath = _object.getObjectPathProperty(
        activeConnectionInterfaceName, 'DHCP6Config');
    return client._getDHCP6Config(objectPath);
  }

  bool get vpn =>
      _object.getBooleanProperty(activeConnectionInterfaceName, 'Vpn');
}

class NetworkManagerIP4Config {
  final String ip4ConfigInterfaceName =
      'org.freedesktop.NetworkManager.IP4Config';

  final _NetworkManagerObject _object;

  NetworkManagerIP4Config(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[ip4ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  List<Map<String, dynamic>> get addressData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'AddressData');
  String get gateway =>
      _object.getStringProperty(ip4ConfigInterfaceName, 'Gateway');
  List<Map<String, dynamic>> get routeData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'RouteData');
  List<Map<String, dynamic>> get nameServerData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'NameServerData');
  List<String> get domains =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'Domains');
  List<String> get searches =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'Searches');
  List<String> get dnsOptions =>
      _object.getStringArrayProperty(ip4ConfigInterfaceName, 'DnsOptions');
  int get dnsPriority =>
      _object.getInt32Property(ip4ConfigInterfaceName, 'DnsPriority');
  List<Map<String, dynamic>> get winsServerData =>
      _object.getDataListProperty(ip4ConfigInterfaceName, 'WinsServerData');
}

class NetworkManagerDHCP4Config {
  final String dhcp4ConfigInterfaceName =
      'org.freedesktop.NetworkManager.DHCP4Config';

  final _NetworkManagerObject _object;

  NetworkManagerDHCP4Config(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dhcp4ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  Map<String, dynamic> get options {
    var value = _object.getCachedProperty(dhcp4ConfigInterfaceName, 'Options');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    return (value as DBusDict).children.map((key, value) => MapEntry(
        (key as DBusString).value, (value as DBusVariant).value.toNative()));
  }
}

class NetworkManagerIP6Config {
  final String ip6ConfigInterfaceName =
      'org.freedesktop.NetworkManager.IP6Config';

  final _NetworkManagerObject _object;

  NetworkManagerIP6Config(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[ip6ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  List<Map<String, dynamic>> get addressData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'AddressData');
  String get gateway =>
      _object.getStringProperty(ip6ConfigInterfaceName, 'Gateway');
  List<Map<String, dynamic>> get routeData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'RouteData');
  List<Map<String, dynamic>> get nameServerData =>
      _object.getDataListProperty(ip6ConfigInterfaceName, 'NameServerData');
  List<String> get domains =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'Domains');
  List<String> get searches =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'Searches');
  List<String> get dnsOptions =>
      _object.getStringArrayProperty(ip6ConfigInterfaceName, 'DnsOptions');
  int get dnsPriority =>
      _object.getInt32Property(ip6ConfigInterfaceName, 'DnsPriority');
}

class NetworkManagerDHCP6Config {
  final String dhcp6ConfigInterfaceName =
      'org.freedesktop.NetworkManager.DHCP6Config';

  final _NetworkManagerObject _object;

  NetworkManagerDHCP6Config(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[dhcp6ConfigInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  Map<String, dynamic> get options {
    var value = _object.getCachedProperty(dhcp6ConfigInterfaceName, 'Options');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    return (value as DBusDict).children.map((key, value) => MapEntry(
        (key as DBusString).value, (value as DBusVariant).value.toNative()));
  }
}

class NetworkManagerAccessPoint {
  final String accessPointInterfaceName =
      'org.freedesktop.NetworkManager.AccessPoint';

  final _NetworkManagerObject _object;

  NetworkManagerAccessPoint(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[accessPointInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  int get flags => _object.getUint32Property(
      accessPointInterfaceName, 'Flags'); // FIXME: enum
  int get wpaFlags => _object.getUint32Property(
      accessPointInterfaceName, 'WpaFlags'); // FIXME: enum
  int get rsnFlags => _object.getUint32Property(
      accessPointInterfaceName, 'RsnFlags'); // FIXME: enum
  List<int> get ssid {
    var value = _object.getCachedProperty(accessPointInterfaceName, 'Ssid');
    if (value == null) {
      return [];
    }
    if (value.signature != DBusSignature('ay')) {
      return [];
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusByte).value)
        .toList();
  }

  int get frequency =>
      _object.getUint32Property(accessPointInterfaceName, 'Frequency');
  String get hwAddress =>
      _object.getStringProperty(accessPointInterfaceName, 'HwAddress');
  int get mode => _object.getUint32Property(
      accessPointInterfaceName, 'Mode'); // FIXME: enum
  int get maxBitrate =>
      _object.getUint32Property(accessPointInterfaceName, 'MaxBitrate');
  int get strength =>
      _object.getByteProperty(accessPointInterfaceName, 'Strength');
  int get lastSeen =>
      _object.getInt32Property(accessPointInterfaceName, 'LastSeen');
}

class _NetworkManagerInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get propertiesChangedStream =>
      propertiesChangedStreamController.stream;

  _NetworkManagerInterface(this.properties);

  void updateProperties(Map<String, DBusValue> changedProperties) {
    properties.addAll(changedProperties);
    propertiesChangedStreamController.add(changedProperties.keys.toList());
  }
}

class _NetworkManagerObject extends DBusRemoteObject {
  final interfaces = <String, _NetworkManagerInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _NetworkManagerInterface(properties);
    });
  }

  void removeInterfaces(List<String> interfaceNames) {
    for (var interfaceName in interfaceNames) {
      interfaces.remove(interfaceName);
    }
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached unsigned 8 bit integer property, or returns null if not present or not the correct type.
  int getByteProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('y')) {
      return null;
    }
    return (value as DBusByte).value;
  }

  /// Gets a cached signed 32 bit integer property, or returns null if not present or not the correct type.
  int getInt32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('i')) {
      return null;
    }
    return (value as DBusInt32).value;
  }

  /// Gets a cached unsigned 32 bit integer property, or returns null if not present or not the correct type.
  int getUint32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('u')) {
      return null;
    }
    return (value as DBusUint32).value;
  }

  /// Gets a cached signed 64 bit integer property, or returns null if not present or not the correct type.
  int getInt64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('x')) {
      return null;
    }
    return (value as DBusInt64).value;
  }

  /// Gets a cached unsigned 64 bit integer property, or returns null if not present or not the correct type.
  int getUint64Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('t')) {
      return null;
    }
    return (value as DBusUint64).value;
  }

  /// Gets a cached string property, or returns null if not present or not the correct type.
  String getStringProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('s')) {
      return null;
    }
    return (value as DBusString).value;
  }

  /// Gets a cached string array property, or returns null if not present or not the correct type.
  List<String> getStringArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('as')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusString).value)
        .toList();
  }

  /// Gets a cached object path property, or returns null if not present or not the correct type.
  DBusObjectPath getObjectPathProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('o')) {
      return null;
    }
    return (value as DBusObjectPath);
  }

  /// Gets a cached object path array property, or returns null if not present or not the correct type.
  List<DBusObjectPath> getObjectPathArrayProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('ao')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusObjectPath))
        .toList();
  }

  /// Gets a cached list of data property, or returns null if not present or not the correct type.
  List<Map<String, dynamic>> getDataListProperty(
      String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('aa{sv}')) {
      return null;
    }
    Map<String, dynamic> convertData(DBusValue value) {
      return (value as DBusDict).children.map((key, value) => MapEntry(
          (key as DBusString).value, (value as DBusVariant).value.toNative()));
    }

    return (value as DBusArray)
        .children
        .map((value) => convertData(value))
        .toList();
  }

  _NetworkManagerObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, 'org.freedesktop.NetworkManager', path) {
    updateInterfaces(interfacesAndProperties);
  }
}

/// A client that connects to NetworkManager.
class NetworkManagerClient {
  final String managerInterfaceName = 'org.freedesktop.NetworkManager';

  /// The bus this client is connected to.
  final DBusClient systemBus;

  /// The root D-Bus NetworkManager object at path '/org/freedesktop'.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _NetworkManagerObject>{};

  /// Creates a new NetworkManager client connected to the system D-Bus.
  NetworkManagerClient(this.systemBus);

  Stream<List<String>> get propertiesChangedStream {
    if (_manager == null) {
      return null;
    }
    return _manager.interfaces['org.freedesktop.NetworkManager']
        .propertiesChangedStreamController.stream;
  }

  /// Connects to the NetworkManager D-Bus objects.
  /// Must be called before accessing methods and properties.
  void connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    _root = DBusRemoteObject(systemBus, 'org.freedesktop.NetworkManager',
        DBusObjectPath('/org/freedesktop'));

    // Subscribe to changes
    await _root.subscribeObjectManagerSignals(
        interfacesAddedCallback: _handleInterfacesAdded,
        interfacesRemovedCallback: _handleInterfacesRemoved,
        propertiesChangedCallback: _handlePropertiesChanged);

    // Find all the objects exported.
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _NetworkManagerObject(systemBus, objectPath, interfacesAndProperties);
    });
  }

  void _handleInterfacesAdded(DBusObjectPath objectPath,
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    var object = _objects[objectPath];
    if (object != null) {
      object.updateInterfaces(interfacesAndProperties);
    } else {
      _objects[objectPath] =
          _NetworkManagerObject(systemBus, objectPath, interfacesAndProperties);
    }
  }

  void _handleInterfacesRemoved(
      DBusObjectPath objectPath, List<String> interfaceNames) {
    var object = _objects[objectPath];
    if (object != null) {
      object.removeInterfaces(interfaceNames);
    }
  }

  void _handlePropertiesChanged(
      DBusObjectPath objectPath,
      String interfaceName,
      Map<String, DBusValue> changedProperties,
      List<String> invalidatedProperties) {
    var object = _objects[objectPath];
    if (object == null) {
      return;
    }

    object.updateProperties(interfaceName, changedProperties);
  }

  List<NetworkManagerDevice> get devices {
    return _getDevices('Devices');
  }

  List<NetworkManagerDevice> get allDevices {
    return _getDevices('AllDevices');
  }

  List<NetworkManagerDevice> _getDevices(String propertyName) {
    if (_manager == null) {
      return null;
    }
    var deviceObjectPaths =
        _manager.getObjectPathArrayProperty(managerInterfaceName, propertyName);
    var devices = <NetworkManagerDevice>[];
    for (var objectPath in deviceObjectPaths) {
      var device = _getDevice(objectPath);
      if (device != null) {
        devices.add(device);
      }
    }

    return devices;
  }

  bool get networkingEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        managerInterfaceName, 'NetworkingEnabled');
  }

  bool get wirelessEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(managerInterfaceName, 'WirelessEnabled');
  }

  bool get wirelessHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        managerInterfaceName, 'WirelessHardwareEnabled');
  }

  bool get wwanEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(managerInterfaceName, 'WwanEnabled');
  }

  bool get wwanHardwareEnabled {
    if (_manager == null) {
      return null;
    }
    return _manager.getBooleanProperty(
        managerInterfaceName, 'WwanHardwareEnabled');
  }

  List<NetworkManagerActiveConnection> get activeConnections {
    if (_manager == null) {
      return null;
    }
    var connectionObjectPaths = _manager.getObjectPathArrayProperty(
        managerInterfaceName, 'ActiveConnections');
    var connections = <NetworkManagerActiveConnection>[];
    for (var objectPath in connectionObjectPaths) {
      var connection = _objects[objectPath];
      if (connection != null) {
        connections.add(NetworkManagerActiveConnection(this, connection));
      }
    }

    return connections;
  }

  NetworkManagerActiveConnection get primaryConnection {
    if (_manager == null) {
      return null;
    }
    var objectPath = _manager.getObjectPathProperty(
        managerInterfaceName, 'PrimaryConnection');
    var connection = _objects[objectPath];
    if (connection == null) {
      return null;
    }

    return NetworkManagerActiveConnection(this, connection);
  }

  String get primaryConnectionType {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(
        managerInterfaceName, 'PrimaryConnectionType');
  }

  /// Gets the version of NetworkManager running.
  String get version {
    if (_manager == null) {
      return null;
    }
    return _manager.getStringProperty(managerInterfaceName, 'Version');
  }

  ConnectivityState get connectivity {
    var value =
        _manager.getUint32Property(managerInterfaceName, 'Connectivity');
    if (value == 1) {
      return ConnectivityState.none;
    } else if (value == 2) {
      return ConnectivityState.portal;
    } else if (value == 3) {
      return ConnectivityState.limited;
    } else if (value == 4) {
      return ConnectivityState.full;
    } else {
      return ConnectivityState.unknown;
    }
  }

  bool get connectivityCheckEnabled {
    return _manager.getBooleanProperty(
        managerInterfaceName, 'ConnectivityCheckEnabled');
  }

  /// Gets the manager object.
  _NetworkManagerObject get _manager =>
      _objects[DBusObjectPath('/org/freedesktop/NetworkManager')];

  /// Gets the settings object.
  NetworkManagerSettings get settings {
    var object =
        _objects[DBusObjectPath('/org/freedesktop/NetworkManager/Settings')];
    if (object == null) {
      return null;
    }
    return NetworkManagerSettings(this, object);
  }

  /// Gets the DNS manager object.
  NetworkManagerDnsManager get dnsManager {
    var object =
        _objects[DBusObjectPath('/org/freedesktop/NetworkManager/DnsManager')];
    if (object == null) {
      return null;
    }
    return NetworkManagerDnsManager(object);
  }

  NetworkManagerDevice _getDevice(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDevice(this, config);
  }

  NetworkManagerSettingsConnection _getConnection(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerSettingsConnection(config);
  }

  NetworkManagerActiveConnection _getActiveConnection(
      DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerActiveConnection(this, config);
  }

  NetworkManagerIP4Config _getIP4Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerIP4Config(config);
  }

  NetworkManagerDHCP4Config _getDHCP4Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDHCP4Config(config);
  }

  NetworkManagerIP6Config _getIP6Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerIP6Config(config);
  }

  NetworkManagerDHCP6Config _getDHCP6Config(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerDHCP6Config(config);
  }

  NetworkManagerAccessPoint _getAccessPoint(DBusObjectPath objectPath) {
    if (objectPath == null) {
      return null;
    }
    var config = _objects[objectPath];
    if (config == null) {
      return null;
    }
    return NetworkManagerAccessPoint(config);
  }
}
