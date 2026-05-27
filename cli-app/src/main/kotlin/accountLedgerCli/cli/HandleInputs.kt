package accountLedgerCli.cli

import account.ledger.library.api.response.AccountResponse
import account_ledger_library.constants.ConstantsNative
import account.ledger.library.models.InsertTransactionResult
import account.ledger.library.models.ViewTransactionsOutput
import account.ledger.library.operations.InsertOperations
import account.ledger.library.utils.AccountUtils
import common.utils.library.utils.ErrorUtilsInteractive
import common.utils.library.utils.ListUtilsInteractive
import io.github.cdimascio.dotenv.Dotenv

fun processChildAccountScreenInput(

    userAccountsMap: LinkedHashMap<UInt, AccountResponse>,
    userId: UInt,
    username: String,
    fromAccount: AccountResponse,
    viaAccount: AccountResponse,
    toAccount: AccountResponse,
    dateTimeInText: String,
    transactionParticulars: String,
    transactionAmount: Float,
    isDevelopmentMode: Boolean,
    dotEnv: Dotenv

): ViewTransactionsOutput {

    val choice: String = readln()
    var accountHomeOutput = InsertTransactionResult(

        isSuccess = false,
        dateTimeInText = dateTimeInText,
        transactionParticulars = transactionParticulars,
        transactionAmount = transactionAmount,
        fromAccount = fromAccount,
        viaAccount = viaAccount,
        toAccount = toAccount
    )
    when (choice) {

        "1" -> {
            accountHomeOutput = handleAccountSelection(

                accountId = ListUtilsInteractive.getValidIndexFromCollectionWithSelectionPromptAndZeroAsBack(

                    map = userAccountsMap,
                    itemSpecification = ConstantsNative.ACCOUNT_TEXT,
                    items = AccountUtils.userAccountsToStringFromList(accounts = userAccountsMap.values.toList())
                ),
                userAccountsMap = userAccountsMap,
                userId = userId,
                username = username,
                fromAccount = fromAccount,
                viaAccount = viaAccount,
                toAccount = toAccount,
                dateTimeInText = dateTimeInText,
                transactionParticulars = transactionParticulars,
                transactionAmount = transactionAmount,
                isDevelopmentMode = isDevelopmentMode,
                dotEnv = dotEnv
            )
        }

        "2" -> {

            accountHomeOutput = handleAccountSelection(

                accountId = searchAccount(

                    userAccountsMap = userAccountsMap,
                    isDevelopmentMode = isDevelopmentMode
                ),
                userAccountsMap = userAccountsMap,
                userId = userId,
                username = username,
                fromAccount = fromAccount,
                viaAccount = viaAccount,
                toAccount = toAccount,
                dateTimeInText = dateTimeInText,
                transactionParticulars = transactionParticulars,
                transactionAmount = transactionAmount,
                isDevelopmentMode = isDevelopmentMode,
                dotEnv = dotEnv
            )
        }

        "3" -> {

            addAccountInteractive(
                userId = userId,
                parentAccount = fromAccount,
                isDevelopmentMode = isDevelopmentMode
            )
            return ViewTransactionsOutput(output = "3", addTransactionResult = accountHomeOutput)
        }

        "0" -> {
            return ViewTransactionsOutput(output = "0", addTransactionResult = accountHomeOutput)
        }

        else -> {
            ErrorUtilsInteractive.printInvalidOptionMessage()
        }
    }
    return ViewTransactionsOutput(output = choice, addTransactionResult = accountHomeOutput)
}

private fun handleAccountSelection(

    accountId: UInt,
    userAccountsMap: LinkedHashMap<UInt, AccountResponse>,
    userId: UInt,
    username: String,
    fromAccount: AccountResponse,
    viaAccount: AccountResponse,
    toAccount: AccountResponse,
    dateTimeInText: String,
    transactionParticulars: String,
    transactionAmount: Float,
    isDevelopmentMode: Boolean,
    dotEnv: Dotenv

): InsertTransactionResult {

    if (accountId != 0u) {

        return Screens.accountHome(

            userId = userId,
            username = username,
            fromAccount = userAccountsMap[accountId]!!,
            viaAccount = viaAccount,
            toAccount = toAccount,
            dateTimeInText = dateTimeInText,
            transactionParticulars = transactionParticulars,
            transactionAmount = transactionAmount,
            isDevelopmentMode = isDevelopmentMode,
            dotEnv = dotEnv
        )
    }
    return InsertTransactionResult(

        isSuccess = false,
        dateTimeInText = dateTimeInText,
        transactionParticulars = transactionParticulars,
        transactionAmount = transactionAmount,
        fromAccount = fromAccount,
        viaAccount = viaAccount,
        toAccount = toAccount
    )
}


internal fun addAccountInteractive(

    userId: UInt,
    parentAccount: AccountResponse,
    isDevelopmentMode: Boolean

) {
    print("Account Name : ")
    val name: String = readln().trim()
    if (name.isEmpty()) {

        println("A/C Name cannot be empty.")
        return
    }

    print("Notes (optional) : ")
    val notes: String = readln().trim()

    print("Account Type [GROUP] : ")
    val accountType: String = readln().trim().ifEmpty { "GROUP" }

    print("Commodity Type [CURRENCY] : ")
    val commodityType: String = readln().trim().ifEmpty { "CURRENCY" }

    print("Commodity Value [INR] : ")
    val commodityValue: String = readln().trim().ifEmpty { "INR" }

    print("Taxable (y/N) : ")
    val taxable: Boolean = readln().trim().equals(other = "y", ignoreCase = true)

    print("Place Holder (y/N) : ")
    val placeHolder: Boolean = readln().trim().equals(other = "y", ignoreCase = true)

    val fullName: String = "${parentAccount.fullName}:$name"

    val isOk: Boolean = InsertOperations.insertAccount(

        fullName = fullName,
        name = name,
        parentAccountId = parentAccount.id,
        accountType = accountType,
        notes = notes,
        commodityType = commodityType,
        commodityValue = commodityValue,
        ownerId = userId,
        taxable = taxable,
        placeHolder = placeHolder,
        isDevelopmentMode = isDevelopmentMode,
        accountManipulationSuccessActions = { println("Account [$fullName] created.") },
        accountManipulationFailureActions = { error: String -> println("Failed to create account : $error") }
    )
    if (!isOk) {

        println("Add Account operation did not complete.")
    }
}


internal fun editAccountInteractive(

    account: AccountResponse,
    isDevelopmentMode: Boolean

) {
    println("Editing Account [${account.fullName}] (press Enter to keep current value)")

    print("Account Name [${account.name}] : ")
    val name: String = readln().trim().ifEmpty { account.name }

    val currentNotes: String = account.notes ?: ""
    print("Notes [${currentNotes}] : ")
    val notes: String = readln().trim().ifEmpty { currentNotes }

    print("Account Type [${account.accountType}] : ")
    val accountType: String = readln().trim().ifEmpty { account.accountType }

    print("Commodity Type [${account.commodityType}] : ")
    val commodityType: String = readln().trim().ifEmpty { account.commodityType }

    print("Commodity Value [${account.commodityValue}] : ")
    val commodityValue: String = readln().trim().ifEmpty { account.commodityValue }

    val currentTaxable: Boolean = account.taxable.equals(other = "T", ignoreCase = true)
    print("Taxable (y/N) [${if (currentTaxable) "Y" else "N"}] : ")
    val taxableInput: String = readln().trim()
    val taxable: Boolean = if (taxableInput.isEmpty()) currentTaxable else taxableInput.equals(other = "y", ignoreCase = true)

    val currentPlaceHolder: Boolean = account.placeHolder.equals(other = "T", ignoreCase = true)
    print("Place Holder (y/N) [${if (currentPlaceHolder) "Y" else "N"}] : ")
    val placeHolderInput: String = readln().trim()
    val placeHolder: Boolean = if (placeHolderInput.isEmpty()) currentPlaceHolder else placeHolderInput.equals(other = "y", ignoreCase = true)

    val parentFullName: String = account.fullName.substringBeforeLast(delimiter = ":", missingDelimiterValue = "")
    val fullName: String = if (parentFullName.isEmpty()) name else "$parentFullName:$name"

    val isOk: Boolean = InsertOperations.updateAccount(

        accountId = account.id,
        fullName = fullName,
        name = name,
        parentAccountId = account.parentAccountId,
        accountType = accountType,
        notes = notes,
        commodityType = commodityType,
        commodityValue = commodityValue,
        taxable = taxable,
        placeHolder = placeHolder,
        isDevelopmentMode = isDevelopmentMode,
        accountManipulationSuccessActions = { println("Account [$fullName] updated.") },
        accountManipulationFailureActions = { error: String -> println("Failed to update account : $error") }
    )
    if (!isOk) {

        println("Edit Account operation did not complete.")
    }
}

internal fun deleteAccountInteractive(

    account: AccountResponse,
    isDevelopmentMode: Boolean

) {
    println("About to delete Account [${account.fullName}] (id=${account.id}).")
    print("Are you sure? (y/N) : ")
    val confirm: String = readln().trim()
    if (!confirm.equals(other = "y", ignoreCase = true)) {

        println("Delete cancelled.")
        return
    }

    val isOk: Boolean = InsertOperations.deleteAccount(

        accountId = account.id,
        isDevelopmentMode = isDevelopmentMode,
        accountManipulationSuccessActions = { println("Account [${account.fullName}] deleted.") },
        accountManipulationFailureActions = { error: String -> println("Failed to delete account : $error") }
    )
    if (!isOk) {

        println("Delete Account operation did not complete.")
    }
}
