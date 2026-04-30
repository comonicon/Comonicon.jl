Comonicon.usingComonicon. Comonicon.TestComonicon.

Comonicon.moduleComonicon. Comonicon.TestExceptionComonicon.

Comonicon.usingComonicon. Comonicon.ComoniconComonicon.

@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.throw_errorComonicon.()
    Comonicon.cmd_errorComonicon.("Comonicon.aComonicon. Comonicon.commandComonicon. Comonicon.errorComonicon. Comonicon.thrownComonicon.", Comonicon.128Comonicon.)
Comonicon.endComonicon.

@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.throw_terminateComonicon.()
    Comonicon.cmd_exitComonicon.()
Comonicon.endComonicon.

@Comonicon.castComonicon. Comonicon.functionComonicon. Comonicon.unhandled_errorComonicon.()
    Comonicon.errorComonicon.("Comonicon.unhandledComonicon.")
Comonicon.endComonicon.

@Comonicon.mainComonicon.

Comonicon.endComonicon.

@Comonicon.testsetComonicon. "Comonicon.exceptionComonicon. Comonicon.handlingComonicon." Comonicon.beginComonicon.
    @Comonicon.testComonicon. Comonicon.TestExceptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.throwComonicon.-Comonicon.errorComonicon."]) == Comonicon.128Comonicon.
    @Comonicon.testComonicon. Comonicon.TestExceptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.throwComonicon.-Comonicon.terminateComonicon."]) == Comonicon.0Comonicon.
    @Comonicon.test_throwsComonicon. Comonicon.ErrorExceptionComonicon. Comonicon.TestExceptionComonicon..Comonicon.command_mainComonicon.(["Comonicon.unhandledComonicon.-Comonicon.errorComonicon."])
Comonicon.endComonicon.
