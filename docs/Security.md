# Security

## What do NHS Digital assess?

NHS Digital require developers of apps and digital tools confirma that a security assessment has been carried out against applicable Open Web Application Security Project standards.

## How we do our assessment

Applications are assessed using [Mobile Security Framework (MobSF)](https://mobsf.github.io/docs/#/), an automated, all-in-one mobile application pen-testing, malware analysis and security assessment framework capable of performing static and dynamic analysis.

## Security Score

App Security Score Calculation

* Every app is given an ideal score of 100 to begin with.
* For every findings with severity <span class="danger">high</span> we reduce 15 from the score.
* For every findings with severity <span class="warning">warning</span> we reduce 10 from the score.
* For every findings with severity <span class="success">good</span> we add 5 to the score.
* If the calculated score is greater than 100, then the app security score is considered as 100.
* And if the calculated score is less than 0, then the app security score is considered as 10.
