Comonicon.usingComonicon. Comonicon.PkgComonicon.
Comonicon.usingComonicon. Comonicon.TestEnvComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

@Comonicon.staticComonicon. Comonicon.ifComonicon. Comonicon.VERSIONComonicon. < Comonicon.vComonicon."Comonicon.1Comonicon..Comonicon.7Comonicon."
    Comonicon.pkgpathComonicon.(Comonicon.pkgComonicon.::Comonicon.PkgComonicon..Comonicon.TypesComonicon..Comonicon.PackageSpecComonicon.) = Comonicon.pkgComonicon..Comonicon.repoComonicon..Comonicon.sourceComonicon.
Comonicon.elseComonicon.
    Comonicon.pkgpathComonicon.(Comonicon.pkgComonicon.::Comonicon.PkgComonicon..Comonicon.TypesComonicon..Comonicon.PackageSpecComonicon.) = Comonicon.pkgComonicon..Comonicon.pathComonicon.
Comonicon.endComonicon.

Comonicon.functionComonicon. Comonicon.collect_libComonicon.()
    Comonicon.rootComonicon. = Comonicon.dirnameComonicon.(@Comonicon.__DIR__Comonicon.)
    Comonicon.lib_dirComonicon. = Comonicon.joinpathComonicon.(Comonicon.rootComonicon., "Comonicon.libComonicon.")
    Comonicon.lib_pkgsComonicon. = []
    Comonicon.lib_namesComonicon. = Comonicon.StringComonicon.[]
    # Comonicon.collectComonicon. Comonicon.librariesComonicon.
    Comonicon.forComonicon. Comonicon.each_libComonicon. Comonicon.inComonicon. Comonicon.readdirComonicon.(Comonicon.lib_dirComonicon.)
        Comonicon.pathComonicon. = Comonicon.joinpathComonicon.(Comonicon.lib_dirComonicon., Comonicon.each_libComonicon.)
        Comonicon.isdirComonicon.(Comonicon.pathComonicon.) || Comonicon.continueComonicon.
        Comonicon.pushComonicon.!(Comonicon.lib_pkgsComonicon., Comonicon.PackageSpecComonicon.(; Comonicon.pathComonicon.))
        Comonicon.pushComonicon.!(Comonicon.lib_namesComonicon., Comonicon.each_libComonicon.)
    Comonicon.endComonicon.
    Comonicon.returnComonicon. Comonicon.lib_pkgsComonicon., Comonicon.lib_namesComonicon.
Comonicon.endComonicon.

Comonicon.functionComonicon. Comonicon.collect_exampleComonicon.()
    Comonicon.rootComonicon. = Comonicon.dirnameComonicon.(@Comonicon.__DIR__Comonicon.)
    Comonicon.example_dirComonicon. = Comonicon.joinpathComonicon.(Comonicon.rootComonicon., "Comonicon.exampleComonicon.")
    Comonicon.example_pkgsComonicon. = []
    Comonicon.example_namesComonicon. = Comonicon.StringComonicon.[]
    # Comonicon.collectComonicon. Comonicon.examplesComonicon.
    Comonicon.forComonicon. Comonicon.each_exampleComonicon. Comonicon.inComonicon. Comonicon.readdirComonicon.(Comonicon.example_dirComonicon.)
        Comonicon.pathComonicon. = Comonicon.joinpathComonicon.(Comonicon.example_dirComonicon., Comonicon.each_exampleComonicon.)
        Comonicon.isdirComonicon.(Comonicon.pathComonicon.) || Comonicon.continueComonicon.
        Comonicon.pushComonicon.!(Comonicon.example_pkgsComonicon., Comonicon.PackageSpecComonicon.(; Comonicon.pathComonicon.))
        Comonicon.pushComonicon.!(Comonicon.example_namesComonicon., Comonicon.each_exampleComonicon.)
    Comonicon.endComonicon.
    Comonicon.returnComonicon. Comonicon.example_pkgsComonicon., Comonicon.example_namesComonicon.
Comonicon.endComonicon.

Comonicon.functionComonicon. Comonicon.generate_example_manifestComonicon.(Comonicon.pkgsComonicon.)
    # Comonicon.weComonicon. Comonicon.needComonicon. Comonicon.toComonicon. Comonicon.generateComonicon. Comonicon.ManifestComonicon..Comonicon.tomlComonicon. Comonicon.forComonicon. Comonicon.examplesComonicon.
    # Comonicon.toComonicon. Comonicon.buildComonicon. Comonicon.sysimgComonicon. Comonicon.andComonicon. Comonicon.appComonicon.
    Comonicon.rootComonicon. = Comonicon.dirnameComonicon.(@Comonicon.__DIR__Comonicon.)
    Comonicon.comonicon_jlComonicon. = Comonicon.PackageSpecComonicon.(Comonicon.pathComonicon. = Comonicon.rootComonicon.)
    Comonicon.forComonicon. Comonicon.pkgComonicon. Comonicon.inComonicon. Comonicon.pkgsComonicon.
        Comonicon.PkgComonicon..Comonicon.activateComonicon.(Comonicon.pkgpathComonicon.(Comonicon.pkgComonicon.))
        Comonicon.PkgComonicon..Comonicon.developComonicon.(Comonicon.comonicon_jlComonicon.)
    Comonicon.endComonicon.
    Comonicon.returnComonicon.
Comonicon.endComonicon.

"""
Comonicon.developComonicon. Comonicon.packageComonicon. Comonicon.setComonicon. Comonicon.atComonicon. Comonicon.currentComonicon. Comonicon.activateComonicon. Comonicon.environmentComonicon..

# Comonicon.ArgsComonicon.

- `Comonicon.setComonicon.`: Comonicon.packageComonicon. Comonicon.setComonicon. Comonicon.nameComonicon., Comonicon.canComonicon. Comonicon.beComonicon. `Comonicon.ComoniconComonicon.`, `Comonicon.libComonicon.`, `Comonicon.exampleComonicon.`, `Comonicon.allComonicon.`.
"""
@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.devComonicon.(Comonicon.setComonicon.::Comonicon.StringComonicon. = "Comonicon.allComonicon.")
    Comonicon.rootComonicon. = Comonicon.dirnameComonicon.(@Comonicon.__DIR__Comonicon.)
    Comonicon.ifComonicon. Comonicon.setComonicon. == "Comonicon.ComoniconComonicon."
        Comonicon.PkgComonicon..Comonicon.developComonicon.(Comonicon.PackageSpecComonicon.(Comonicon.pathComonicon. = Comonicon.rootComonicon.))
    Comonicon.elseifComonicon. Comonicon.setComonicon. == "Comonicon.libComonicon."
        Comonicon.lib_pkgsComonicon., Comonicon.lib_namesComonicon. = Comonicon.collect_libComonicon.()
        Comonicon.foreachComonicon.(Comonicon.PkgComonicon..Comonicon.developComonicon., Comonicon.lib_pkgsComonicon.)
    Comonicon.elseifComonicon. Comonicon.setComonicon. == "Comonicon.exampleComonicon."
        Comonicon.example_pkgsComonicon., Comonicon.example_namesComonicon. = Comonicon.collect_exampleComonicon.()
        Comonicon.foreachComonicon.(Comonicon.PkgComonicon..Comonicon.developComonicon., Comonicon.example_pkgsComonicon.)
    Comonicon.endComonicon.
Comonicon.endComonicon.

"""
Comonicon.runComonicon. Comonicon.ComoniconComonicon. Comonicon.testsComonicon..

# Comonicon.ArgsComonicon.

- `Comonicon.testsetComonicon.`: Comonicon.whichComonicon. Comonicon.testsetComonicon. Comonicon.toComonicon. Comonicon.runComonicon., Comonicon.canComonicon. Comonicon.beComonicon. `Comonicon.allComonicon.`, `Comonicon.ComoniconComonicon.`, `Comonicon.libComonicon.`, `Comonicon.exampleComonicon.`.

# Comonicon.FlagsComonicon.

- `--Comonicon.coverageComonicon.`: Comonicon.enableComonicon. Comonicon.codeComonicon. Comonicon.coverageComonicon. Comonicon.trackingComonicon..
"""
@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.runtestComonicon.(Comonicon.testsetComonicon.::Comonicon.StringComonicon. = "Comonicon.allComonicon."; Comonicon.coverageComonicon.::Comonicon.BoolComonicon. = Comonicon.falseComonicon.)
    Comonicon.rootComonicon. = Comonicon.dirnameComonicon.(@Comonicon.__DIR__Comonicon.)
    Comonicon.comonicon_jlComonicon. = Comonicon.PackageSpecComonicon.(Comonicon.pathComonicon. = Comonicon.rootComonicon.)

    Comonicon.lib_pkgsComonicon., Comonicon.lib_namesComonicon. = Comonicon.collect_libComonicon.()
    Comonicon.example_pkgsComonicon., Comonicon.example_namesComonicon. = Comonicon.collect_exampleComonicon.()
    Comonicon.generate_example_manifestComonicon.(Comonicon.example_pkgsComonicon.)

    Comonicon.TestEnvComonicon..Comonicon.activateComonicon.() Comonicon.doComonicon.
        Comonicon.PkgComonicon..Comonicon.developComonicon.(Comonicon.comonicon_jlComonicon.)
        Comonicon.foreachComonicon.(Comonicon.PkgComonicon..Comonicon.developComonicon., Comonicon.lib_pkgsComonicon.)
        Comonicon.foreachComonicon.(Comonicon.PkgComonicon..Comonicon.developComonicon., Comonicon.example_pkgsComonicon.)

        Comonicon.PkgComonicon..Comonicon.statusComonicon.()
        # Comonicon.startComonicon. Comonicon.testComonicon.
        Comonicon.ifComonicon. Comonicon.testsetComonicon. == "Comonicon.allComonicon."
            Comonicon.PkgComonicon..Comonicon.testComonicon.("Comonicon.ComoniconComonicon."; Comonicon.coverageComonicon.)
            Comonicon.PkgComonicon..Comonicon.testComonicon.(Comonicon.lib_namesComonicon.; Comonicon.coverageComonicon.)
            Comonicon.PkgComonicon..Comonicon.testComonicon.(Comonicon.example_namesComonicon.; Comonicon.coverageComonicon.)
        Comonicon.elseifComonicon. Comonicon.testsetComonicon. == "Comonicon.ComoniconComonicon."
            Comonicon.PkgComonicon..Comonicon.testComonicon.("Comonicon.ComoniconComonicon."; Comonicon.coverageComonicon.)
        Comonicon.elseifComonicon. Comonicon.testsetComonicon. == "Comonicon.exampleComonicon."
            Comonicon.PkgComonicon..Comonicon.testComonicon.(Comonicon.example_namesComonicon.; Comonicon.coverageComonicon.)
        Comonicon.elseifComonicon. Comonicon.testsetComonicon. == "Comonicon.libComonicon."
            Comonicon.PkgComonicon..Comonicon.testComonicon.(Comonicon.lib_namesComonicon.; Comonicon.coverageComonicon.)
        Comonicon.endComonicon.
    Comonicon.endComonicon.
Comonicon.endComonicon.

@Comonicon.mainComonicon.
