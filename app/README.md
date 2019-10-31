## Documentation
To generate documentation, run 
```
dartdoc
```
in the project's root directory. To view documentation, first run
```
pub global activate dhttpd
```
then, assuming `dhttpd` is in your system path, run
```
dhttpd --path doc/api
```
You can view the documentation at `http://localhost:8080`. See [https://github.com/dart-lang/dartdoc](https://github.com/dart-lang/dartdoc) for more details.