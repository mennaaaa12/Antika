import 'package:antika/core/constant/color/my_color.dart';
import 'package:antika/core/routing/app_routes.dart';
import 'package:antika/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp( Antika(appRouter: AppRouter()));
}


class Antika extends StatelessWidget {
  const Antika({super.key, required this.appRouter});
 final AppRouter appRouter;
  @override
  Widget build(BuildContext context) { 
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        
        title: 'Antika',      
        theme: ThemeData(
          primaryColor: MyColor.primaryBackGroundColor,
          scaffoldBackgroundColor: MyColor.primaryBackGroundColor,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.homeScreen,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}