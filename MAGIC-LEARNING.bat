@echo off
color 0A
cls
echo.
echo  ███╗   ███╗ █████╗  ██████╗ ██╗ ██████╗
echo  ████╗ ████║██╔══██╗██╔════╝ ██║██╔════╝
echo  ██╔████╔██║███████║██║  ███╗██║██║     
echo  ██║╚██╔╝██║██╔══██║██║   ██║██║██║     
echo  ██║ ╚═╝ ██║██║  ██║╚██████╔╝██║╚██████╗
echo  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝
echo.
echo  LEARNING SYSTEM - From Zero to Netflix Engineer
echo ================================================
echo.
echo  Choose how you want to learn:
echo.
echo  Choose your SUPERPOWER:
echo.
echo  1. BEGINNER MAGIC    - "I know nothing but want everything"
echo  2. SPEED DEMON       - "Teach me FAST, I can handle it"  
echo  3. HANDS-ON WARRIOR  - "Skip theory, show me the CODE"
echo  4. GAME MODE         - "Make it fun, I learn by playing"
echo  5. NETFLIX CHALLENGE - "I want to work at Netflix NOW"
echo  6. SURPRISE ME       - "Just blow my mind"
echo.
echo  7. INSTANT WINS     - "Make me feel smart in 5 minutes"
echo  8. MIND BLOWN       - "Explain complex stuff simply"
echo.
set /p magic="What's your learning superpower? (1-8): "

if "%magic%"=="1" goto BEGINNER_MAGIC
if "%magic%"=="2" goto SPEED_DEMON  
if "%magic%"=="3" goto HANDS_ON
if "%magic%"=="4" goto GAME_MODE
if "%magic%"=="5" goto NETFLIX_CHALLENGE
if "%magic%"=="6" goto SURPRISE_ME
if "%magic%"=="7" goto INSTANT_WINS
if "%magic%"=="8" goto MIND_BLOWN

:BEGINNER_MAGIC
cls
echo.
echo BEGINNER MAGIC ACTIVATED
echo.
echo Starting your transformation from ZERO to HERO...
echo.
echo Opening Development Track - perfect for beginners!
start "" "docs\chapters\development\README.md"
echo.
echo Your mission: Read this like a story, not documentation
echo Pro tip: Don't worry about remembering everything
echo Next: Come back and run this script again!
goto END

:SPEED_DEMON
cls
echo.
echo SPEED DEMON MODE ACTIVATED
echo.
echo Buckle up! We're going FAST...
echo.
echo Opening 3 tracks simultaneously:
start "" "docs\chapters\development\README.md"
start "" "docs\chapters\kubernetes\README.md"
start "" "docs\chapters\enterprise-devops\README.md"
echo.
echo Challenge: Master all 3 in 30 days
echo Timer starts NOW!
goto END

:HANDS_ON
cls
echo.
echo HANDS-ON WARRIOR MODE ACTIVATED
echo.
echo Forget theory - let's BUILD stuff!
echo.
echo Opening instant wins for immediate practice:
start "" "interactive-learning\exercises\INSTANT-WIN.md"
start "" "docs\chapters\kubernetes\README.md"
echo.
echo Your mission: Complete these labs RIGHT NOW
echo No reading - just DO and LEARN by doing
goto END

:GAME_MODE
cls
echo.
echo GAME MODE ACTIVATED
echo.
echo Welcome to DevOps: The Game!
echo.
echo Your Stats:
echo    Level: 1 (Noob)
echo    XP: 0/1000
echo    Skills: None yet
echo    Salary: $50k (ouch!)
echo.
echo First Quest: Complete instant wins for XP boost!
start "" "interactive-learning\exercises\INSTANT-WIN.md"
start "" "interactive-learning\challenges\README.md"
echo.
echo Complete challenges to level up!
echo Unlock new skills and higher salaries!
goto END

:NETFLIX_CHALLENGE
cls
echo.
echo NETFLIX CHALLENGE ACTIVATED
echo.
echo Think you can handle Netflix-level engineering?
echo.
echo Your Mission: Build Netflix's Architecture
echo Stakes: $200k+ salary if you succeed
echo Time Limit: 90 days
echo.
echo Phase 1: Start with instant wins to build confidence
start "" "interactive-learning\exercises\INSTANT-WIN.md"
echo.
echo Phase 2: Master Kubernetes like Netflix
start "" "docs\chapters\kubernetes\README.md"
echo.
echo Phase 3: Enterprise patterns
start "" "docs\chapters\enterprise-devops\README.md"
echo.
echo This is REAL Netflix engineering!
goto END

:SURPRISE_ME
cls
echo.
echo SURPRISE MODE ACTIVATED
echo.
echo Calculating the PERFECT learning path for you...
timeout /t 3 /nobreak >nul
echo.
echo SURPRISE! You're starting with instant wins!
echo Why? Build confidence first, then tackle complex stuff
echo.
echo Opening your surprise learning path:
start "" "interactive-learning\exercises\INSTANT-WIN.md"
start "" "docs\chapters\kubernetes\README.md"
echo.
echo Trust the process - this will blow your mind!
goto END

:INSTANT_WINS
cls
echo.
echo INSTANT_WINS MODE ACTIVATED
echo.
echo Get ready for dopamine hits!
echo.
echo Opening your confidence booster:
start "" "interactive-learning\exercises\INSTANT-WIN.md"
echo.
echo Your mission: Complete 3 wins in 15 minutes
echo Feel like a genius immediately!
goto END

:MIND_BLOWN
cls
echo.
echo MIND BLOWN MODE ACTIVATED
echo.
echo Complex stuff made stupidly simple!
echo.
echo Opening your mind-blowing guide:
start "" "interactive-learning\MIND-BLOWN.md"
echo.
echo Your mission: Understand everything in 3 seconds
echo Prepare to have your mind blown!
goto END

:END
echo.
echo ================================================
echo  MAGIC LEARNING SYSTEM ACTIVATED!
echo ================================================
echo.
echo Learning system activated!
echo.
echo Pick a track and start practicing.
echo The best way to learn is by doing.
echo.
echo TIP: Install Typora or MarkText for better markdown viewing!
echo Or use VS Code which renders markdown beautifully.
echo.
pause