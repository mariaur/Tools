#include "stdafx.h"

VOID
Usage(
VOID
)
{
    wprintf(L"\n");
    wprintf(L"USAGE: chpass user [domain]\n");
}


BOOL
ReadStringFromConsole(
_In_ UINT cchMax,
_Out_capcount_(cchMax) WCHAR* wszStrBuf
)
{
    BOOL bRet, bDone;
    WCHAR wch;
    UINT n;

    bDone = FALSE, bRet = TRUE;
    n = 0;

    for (;;)
    {
        wch = _getwch();

        switch (wch)
        {
        case 0x1b:
            bRet = FALSE, bDone = TRUE;
            break;

        case 0x0a:
        case 0x0d:
            bRet = TRUE, bDone = TRUE;
            break;

        case 0x08:
            if (n > 0)
            {
                n--;

                _putwch(wch);
                _putwch(L' ');
                _putwch(wch);
            }
            break;

        default:
            wszStrBuf[n++] = wch;
            _putwch(L'*');
            break;
        }


        if (n >= cchMax)
        {
            bDone = TRUE;
        }

        if (bDone != FALSE)
        {
            break;
        }
    }

    wszStrBuf[n] = 0;

    wprintf(L"\n");
    return bRet;
}


int
__cdecl
wmain(
_In_ int nArgc,
_In_count_(nArgc) LPWSTR* ppwszArgs
)
{
    LPCWSTR pwszUser, pwszDomain;

    WCHAR wszDomain[MAX_PATH];

    WCHAR wszOldPass[MAX_PATH];
    WCHAR wszNewPass[MAX_PATH];
    WCHAR wszNewPass2[MAX_PATH];

    BOOL bContinue;
    DWORD dwErr;
    int nRet;

    nRet = EXIT_SUCCESS;

    if ((nArgc < 2 || nArgc > 3) ||
        (_wcsicmp(ppwszArgs[1], L"/?") == 0) ||
        (_wcsicmp(ppwszArgs[1], L"-?") == 0))
    {
        Usage();

        nRet = EXIT_FAILURE;
    }

    if (nRet == EXIT_SUCCESS)
    {
        pwszUser = ppwszArgs[1];

        if (nArgc > 2)
        {
            pwszDomain = ppwszArgs[2];
        }
        else
        {
            pwszDomain = NULL;
        }

        wprintf(L"\n");

        if (pwszDomain == NULL)
        {
            if (GetEnvironmentVariable(L"USERDOMAIN", wszDomain, ARRAYSIZE(wszDomain)) > 0)
            {
                pwszDomain = wszDomain;
            }
            else
            {
                pwszDomain = L".";
            }
        }

        wprintf(L"Changing password for [%s\\%s] ...\n",
            pwszDomain, pwszUser);

        wprintf(L"\n");

        wprintf(L"Old Password: ");
        bContinue = ReadStringFromConsole(ARRAYSIZE(wszOldPass), wszOldPass);

        if (bContinue != FALSE)
        {
            SecureZeroMemory(wszNewPass, sizeof(wszNewPass));

            wprintf(L"New Password: ");
            bContinue = ReadStringFromConsole(ARRAYSIZE(wszNewPass), wszNewPass);
        }

        if (bContinue != FALSE)
        {
            SecureZeroMemory(wszNewPass2, sizeof(wszNewPass2));

            wprintf(L"Re-type Password: ");
            bContinue = ReadStringFromConsole(ARRAYSIZE(wszNewPass2), wszNewPass2);
        }

        if (bContinue != FALSE)
        {
            if (memcmp(wszNewPass, wszNewPass2, sizeof(wszNewPass)))
            {
                wprintf(L"\n");
                wprintf(L"Passwords did not match. ");

                nRet = EXIT_FAILURE;
            }
            else
            {
                dwErr = NetUserChangePassword(pwszDomain, pwszUser, wszOldPass, wszNewPass);

                nRet = (dwErr == ERROR_SUCCESS);

                if (dwErr != ERROR_SUCCESS)
                {
                    wprintf(L"\n");
                    wprintf(L"NetUserChangePassword failed. Error code - %d\n", dwErr);
                }
                else
                {
                    wprintf(L"\n");
                    wprintf(L"Success. ");
                }
            }

        }
        else
        {
            wprintf(L"\n");
            wprintf(L"Cancelled. ");
        }
    }

    wprintf(L"\n");

    //
    // Clear password buffers
    //

    SecureZeroMemory(wszOldPass, sizeof(wszOldPass));

    SecureZeroMemory(wszNewPass, sizeof(wszNewPass));

    SecureZeroMemory(wszNewPass2, sizeof(wszNewPass2));

    return nRet;
}
