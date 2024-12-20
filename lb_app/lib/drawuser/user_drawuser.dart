import 'package:flutter/material.dart';
import 'package:lb_app/apis/estudiante_api.dart';
import 'package:lb_app/modelo/EstudianteModelo.dart';
import 'package:lb_app/theme/AppTheme.dart';
import 'package:lb_app/login/login_user.dart';
import 'package:lb_app/util/TokenUtil.dart';


class UserDrawuser extends StatefulWidget {
  const UserDrawuser({
    super.key,
    required this.screenIndex,
    required this.iconAnimationController,
    required this.callBackIndex,
  });

  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<UserDrawuser> {
  List<DrawerList>? drawerList;
  String? estudianteNombre;
  String? estudianteApellido;
  String? estudianteApellidoU;
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    setDrawerListArray();
    super.initState();
    _fetchEstudianteData(); // Llamada al método para cargar los datos del estudiante
  }

  // Método para obtener los datos del estudiante asociado al authUserId
  Future<void> _fetchEstudianteData() async {
    final api = EstudianteApi.create(); // Crear instancia de la API
    try {
      final estudiantes =
          await api.listarEstudiantes(); // Obtener todos los estudiantes
      print("Estudiantes recuperados: ");
      estudiantes.forEach((est) {
        print("Estudiante: ${est.nombre}, AuthUserId: ${est.authUserId}");
      });

      final authUserId =
          TokenUtil.authUserId; // Obtener el authUserId del token
      print("authUserId: $authUserId");

      // Asegurarnos de que authUserId sea un número entero
      final int? authUserIdInt = int.tryParse(authUserId.toString());
      if (authUserIdInt == null) {
        print("El authUserId no es válido.");
        return;
      }

      // Buscar al estudiante con el authUserId correspondiente
      final estudiante = estudiantes.firstWhere(
        (est) =>
            est.authUserId == authUserIdInt, // Comparación estricta con enteros
        orElse: () {
          print(
              "No se encontró un estudiante con el authUserId: $authUserIdInt");
          return EstudianteModelo(
              id: 0,
              nombre: 'Anonimo',
              apellidoPaterno: 'Anonimo',
              apellidoMaterno: '',
              dni: 0,
              carrera: '',
              universidad: '',
              habilidades: '',
              horasCompletadas: '',
              authUserId: 0,
              authUserDto: AuthUserDto(id: 0, userName: ''));
        },
      );

      if (estudiante.authUserId != 0) {
        final estudianteDetalles = await api.buscarEstudiante(estudiante
            .id); // Llamamos al endpoint para obtener los detalles completos
        setState(() {
          estudianteNombre = estudianteDetalles.nombre;
          estudianteApellido = estudianteDetalles.apellidoPaterno;
          estudianteApellidoU = estudianteDetalles.apellidoMaterno;
          isLoading = false;
        });
      } else {
        setState(() {
          estudianteNombre = 'Anonimo';
          estudianteApellido = 'Anonimo';
          estudianteApellidoU = 'Anonimo';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error al obtener los datos del estudiante: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
          index: DrawerIndex.HOME,
          labelName: 'Principal',
          icon: Icon(Icons.home)),
      DrawerList(
          index: DrawerIndex.Invite,
          labelName: 'Perfil',
          icon: Icon(Icons.group)),
      DrawerList(
          index: DrawerIndex.FeedBack,
          labelName: 'Postulaciones',
          icon: Icon(Icons.group)),
      DrawerList(
          index: DrawerIndex.Share,
          labelName: 'Ofertas',
          icon: Icon(Icons.group)),
      DrawerList(
          index: DrawerIndex.Testing,
          labelName: 'Notificaciones',
          icon: Icon(Icons.group)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(
                            1.0 - (widget.iconAnimationController.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(
                                      begin: 0.0, end: 24.0)
                                  .animate(CurvedAnimation(
                                      parent: widget.iconAnimationController,
                                      curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Center(
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/imagen/perfil.png'),
                              radius: 40,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: isLoading
                        ? CircularProgressIndicator() // Muestra un spinner mientras carga
                        : Text(
                            "${estudianteNombre} ${estudianteApellido} ${estudianteApellidoU} (Usuario)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 1),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(height: 1),
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  'Salir',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.power_settings_new,
                    color: const Color.fromARGB(255, 163, 19, 8)),
                onTap: () {
                  onTapped();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }

  void onTapped() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        return LoginPage();
      }),
      ModalRoute.withName('/'),
    );
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(width: 6.0, height: 46.0),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Colors.blue
                                  : AppTheme.themeData.primaryColor),
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index
                              ? Colors.blue
                              : AppTheme.themeData.primaryColor),
                  const Padding(padding: EdgeInsets.all(4.0)),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Colors.blue
                          : AppTheme.themeData.primaryColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) *
                                (1.0 -
                                    widget.iconAnimationController.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  FeedBack,
  Help,
  Share,
  About,
  Invite,
  Testing,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    required this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;
}
