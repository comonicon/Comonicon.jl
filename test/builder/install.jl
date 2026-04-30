Comonicon.moduleComonicon. Comonicon.TestBuilderInstallComonicon.

Comonicon.usingComonicon. Comonicon.TestComonicon.
Comonicon.usingComonicon. Comonicon.ScratchComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon..ConfigsComonicon.
Comonicon.usingComonicon. Comonicon.ComoniconComonicon..BuilderComonicon.: Comonicon.ensure_pathComonicon., Comonicon.entryfile_scriptComonicon., Comonicon.completion_scriptComonicon., Comonicon.detect_rcfileComonicon.

@Comonicon.testsetComonicon. "Comonicon.ensure_pathComonicon." Comonicon.beginComonicon.
    Comonicon.pathComonicon. = Comonicon.tempnameComonicon.()
    @Comonicon.testComonicon. Comonicon.ispathComonicon.(Comonicon.pathComonicon.) == Comonicon.falseComonicon.
    Comonicon.ensure_pathComonicon.(Comonicon.pathComonicon.)
    @Comonicon.testComonicon. Comonicon.ispathComonicon.(Comonicon.pathComonicon.) == Comonicon.trueComonicon.
Comonicon.endComonicon.

Comonicon.moduleComonicon. Comonicon.TestInstallComonicon.

Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

@Comonicon.castComonicon. Comonicon.fooComonicon.(Comonicon.xComonicon.) = Comonicon.0Comonicon.
@Comonicon.castComonicon. Comonicon.gooComonicon.(Comonicon.xComonicon.) = Comonicon.1Comonicon.

@Comonicon.mainComonicon.

Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.entryfile_scriptComonicon." Comonicon.beginComonicon.
    Comonicon.optionsComonicon. = Comonicon.ConfigsComonicon..Comonicon.ComoniconComonicon.(Comonicon.nameComonicon. = "Comonicon.testComonicon.")
    Comonicon.scriptComonicon. = Comonicon.entryfile_scriptComonicon.(Comonicon.TestInstallComonicon., Comonicon.optionsComonicon.)
    Comonicon.ifComonicon. Comonicon.SysComonicon..Comonicon.iswindowsComonicon.()
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("@Comonicon.echoComonicon. Comonicon.offComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("Comonicon.setComonicon. Comonicon.JULIA_PROJECTComonicon.=$(Comonicon.get_scratchComonicon.!(Comonicon.TestInstallComonicon., "Comonicon.envComonicon."))", Comonicon.scriptComonicon.)
        Comonicon.julia_exeComonicon. = Comonicon.joinpathComonicon.(Comonicon.SysComonicon..Comonicon.BINDIRComonicon., Comonicon.BaseComonicon..Comonicon.julia_exenameComonicon.())
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("$Comonicon.julia_exeComonicon. ^\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.startupComonicon.-Comonicon.fileComonicon.=Comonicon.noComonicon. ^\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.colorComonicon.=Comonicon.yesComonicon. ^\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.compileComonicon.=Comonicon.yesComonicon. ^\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.optimizeComonicon.=Comonicon.2Comonicon. ^\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.(
            "Comonicon.usingComonicon. Comonicon.MainComonicon..Comonicon.TestBuilderInstallComonicon..Comonicon.TestInstallComonicon.; Comonicon.exitComonicon.(Comonicon.TestInstallComonicon..Comonicon.command_mainComonicon.())",
            Comonicon.scriptComonicon.,
        )
    Comonicon.elseComonicon.
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("#!/Comonicon.usrComonicon./Comonicon.binComonicon./Comonicon.envComonicon. Comonicon.bashComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("Comonicon.JULIA_PROJECTComonicon.=$(Comonicon.get_scratchComonicon.!(Comonicon.TestInstallComonicon., "Comonicon.envComonicon."))", Comonicon.scriptComonicon.)
        Comonicon.julia_exeComonicon. = Comonicon.joinpathComonicon.(Comonicon.SysComonicon..Comonicon.BINDIRComonicon., Comonicon.BaseComonicon..Comonicon.julia_exenameComonicon.())
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("Comonicon.execComonicon. $Comonicon.julia_exeComonicon. \\\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.startupComonicon.-Comonicon.fileComonicon.=Comonicon.noComonicon. \\\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.colorComonicon.=Comonicon.yesComonicon. \\\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.compileComonicon.=Comonicon.yesComonicon. \\\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("--Comonicon.optimizeComonicon.=Comonicon.2Comonicon. \\\Comonicon.nComonicon.", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("-- \"\${Comonicon.BASH_SOURCEComonicon.[Comonicon.0Comonicon.]}\"", Comonicon.scriptComonicon.)
        @Comonicon.testComonicon. Comonicon.occursinComonicon.(
            "Comonicon.usingComonicon. Comonicon.MainComonicon..Comonicon.TestBuilderInstallComonicon..Comonicon.TestInstallComonicon.\Comonicon.nexitComonicon.(Comonicon.TestInstallComonicon..Comonicon.command_mainComonicon.())",
            Comonicon.scriptComonicon.,
        )
    Comonicon.endComonicon.
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.testComonicon. Comonicon.completionComonicon. Comonicon.scriptComonicon." Comonicon.beginComonicon.
    Comonicon.optionsComonicon. = Comonicon.ConfigsComonicon..Comonicon.ComoniconComonicon.(Comonicon.nameComonicon. = "Comonicon.testComonicon.")
    Comonicon.withenvComonicon.("Comonicon.SHELLComonicon." => "/Comonicon.binComonicon./Comonicon.zshComonicon.") Comonicon.doComonicon.
        Comonicon.scriptComonicon. = Comonicon.completion_scriptComonicon.(Comonicon.TestInstallComonicon., Comonicon.optionsComonicon., "Comonicon.zshComonicon.")
        @Comonicon.testComonicon. Comonicon.occursinComonicon.("#Comonicon.compdefComonicon. Comonicon._testinstallComonicon. Comonicon.testinstallComonicon. \Comonicon.nComonicon.", Comonicon.scriptComonicon.)
    Comonicon.endComonicon.

    Comonicon.withenvComonicon.("Comonicon.SHELLComonicon." => "/Comonicon.binComonicon./Comonicon.fakeshComonicon.") Comonicon.doComonicon.
        @Comonicon.test_throwsComonicon. Comonicon.ErrorExceptionComonicon. Comonicon.completion_scriptComonicon.(Comonicon.TestInstallComonicon., Comonicon.optionsComonicon., "/Comonicon.binComonicon./Comonicon.fakeshComonicon.")
    Comonicon.endComonicon.
Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.detect_rcfileComonicon." Comonicon.beginComonicon.
    Comonicon.answerComonicon. = Comonicon.joinpathComonicon.((Comonicon.haskeyComonicon.(Comonicon.ENVComonicon., "Comonicon.ZDOTDIRComonicon.") ? Comonicon.ENVComonicon.["Comonicon.ZDOTDIRComonicon."] : Comonicon.homedirComonicon.()), ".Comonicon.zshrcComonicon.")
    Comonicon.withenvComonicon.("Comonicon.SHELLComonicon." => "Comonicon.zshComonicon.") Comonicon.doComonicon.
        @Comonicon.testComonicon. Comonicon.detect_rcfileComonicon.("Comonicon.zshComonicon.") == Comonicon.answerComonicon.
    Comonicon.endComonicon.

    Comonicon.withenvComonicon.("Comonicon.SHELLComonicon." => "Comonicon.zshComonicon.", "Comonicon.ZDOTDIRComonicon." => "Comonicon.zsh_dirComonicon.") Comonicon.doComonicon.
        @Comonicon.testComonicon. Comonicon.detect_rcfileComonicon.("Comonicon.zshComonicon.") == Comonicon.joinpathComonicon.("Comonicon.zsh_dirComonicon.", ".Comonicon.zshrcComonicon.")
    Comonicon.endComonicon.
Comonicon.endComonicon.

Comonicon.endComonicon. # Comonicon.TestBuilderInstallComonicon.
