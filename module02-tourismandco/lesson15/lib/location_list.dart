import 'dart:async';
import 'package:flutter/material.dart';
import 'models/location.dart';
import 'location_detail.dart';
import 'styles.dart';

class LocationList extends StatefulWidget {
  @override
  createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  List<Location> locations = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Locations", style: Styles.navBarTitle)),
        body: RefreshIndicator(
            onRefresh: loadData,
            child: Column(children: [
              renderProgressBar(context),
              Expanded(child: renderListView(context))
            ])));
  }

  Future<void> loadData() async {
    if (this.mounted) {
      setState(() => this.loading = true);
      Timer(Duration(milliseconds: 3000), () async {
        final locations = await Location.fetchAll();
        setState(() {
          this.locations = locations;
          this.loading = false;
        });
      });
    }
  }

  Widget renderProgressBar(BuildContext context) {
    return (this.loading
        ? LinearProgressIndicator(
            value: null,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey))
        : Container());
  }

  Widget renderListView(BuildContext context) {
    return ListView.builder(
      itemCount: this.locations.length,
      itemBuilder: _listViewItemBuilder,
    );
  }

  Widget _listViewItemBuilder(BuildContext context, int index) {
    final location = this.locations[index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(location),
      title: _itemTitle(location),
      onTap: () => _navigateToLocationDetail(context, location.id),
    );
  }

  void _navigateToLocationDetail(BuildContext context, int locationID) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => LocationDetail(locationID)));
  }

  Widget _itemThumbnail(Location location) {
    Image image;
    try {
      image = Image.network(location.url, fit: BoxFit.fitWidth);
    } catch (e) {
      print("could not load image ${location.url}");
    }
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: image,
    );
  }

  Widget _itemTitle(Location location) {
    return Text('${location.name}', style: Styles.textDefault);
  }
}
