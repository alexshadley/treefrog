import 'dart:core';

import 'package:flutter/material.dart';

import 'package:leapfrog/config.dart';
import 'package:leapfrog/views/map_page.dart';
import 'package:leapfrog/views/transfer_menu_page.dart';

/// A placeholder. This will be replaced with the map when it's ready, but
/// I needed somewhere to navigate to after a successful login.
class Menu extends StatefulWidget {

  final _email;
  final _config;

  /// Initializes the placeholder page.
  /// [email] is the email of the currently-signed-in user.
  Menu(String email, Config config) :
    _email = email,
    _config = config;

  /// Creates the page state.
  @override
  _MenuState createState() => new _MenuState(_email, _config);
}

/// The state of the placeholder page.
class _MenuState extends State<Menu> {

  final _email;
  final _config;

  _MenuState(String email, Config config) :
    _email = email,
    _config = config;
  
  void _startTransfer() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => new TransferMenuPage(_email, _config)));
  }

  /// Builds the page [Widget].
  Widget build(BuildContext context) {
    return new Scaffold (
      body: new Stack(
        children: <Widget>[
          _buildBackground(),
          new Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildLeftColumn(),
                _buildRightColumn(),
              ],
            )
          )
        ]
      )
    );
  }

  /// Builds the background, containing a single image
  Widget _buildBackground() {
    return new Container(
      child: Image.asset(
        _config.getValue('home_screen_img'),
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fitHeight,
        alignment: Alignment(0.5, 0), // TODO Possibly change when true image is found
      ),
    );
  }

  /// Builds left column for the menu
  ///   Contains name for the frog
  ///   Contains list of recent transfers
  Widget _buildLeftColumn() {
    return new Expanded(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'NAME', // TODO Replace with name of user's frog
            style: TextStyle(fontSize: 30.0),
          ),
          SizedBox( // Vertical ListView
            height: 300,
            child: _buildTransfers(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of transfers of user's frog
  ///   TODO Change to recent transfers
  Widget _buildTransfers() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Text(index.toString()),
        );
      },
    );
    // return ListView.builder(
    //   padding: const EdgeInsets.all(16.0),
    //   itemBuilder: (context, i) {
    //     if (i.isOdd) return Divider();

    //     return ListTile(
    //       title: Text('Test $i'),
    //     );
    //   });
  }

  /// Builds the column on the right side of the home screen
  ///   Contains routing buttons:
  ///     Map - Goes to the map
  ///     Transfer - Goes to the transfer screen
  Widget _buildRightColumn() {
    return new Expanded(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildRouteBtn('Map', new MapPage(_config, _email)),
          _buildRouteBtn('Transfer', new TransferMenuPage(_email, _config)),
        ],
      )
    );
  }

  /// Builds a button to handle routing to a different page
  ///   name - The text on the button
  ///   page - The page to route to
  Widget _buildRouteBtn(String name, StatefulWidget page) {
    return new Container(
      margin: new EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
      child: new SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          color: new Color(int.parse(_config.getValue("form_button_background"), radix: 16)),
          splashColor: Colors.lightGreen,
          child: new Text(name, style: TextStyle(fontSize: 20.0)),
          onPressed: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => page)),
        ),
      ),
    );
  }
}