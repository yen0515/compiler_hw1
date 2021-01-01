# hw1 report

|Field|Value|
|-:|:-|
|Name|黃彥慈|
|ID|0716088|

## How much time did you spend on this project

15 hours.

## Project overview

首先是keyword的部分 當scanner掃到有定義的keyword如if then等時，會觸發相對應的function，如若掃到array時，便會觸發TOKEN("KWarray")，再交由最一開始define的TOKEN()做處理。
再來的delimiters、arthimetic、logical跟relational便是大同小異，例如掃到','時，便會觸發TOKEN_CHAR(',') 掃到and時則會觸發TOKEN("and")
接下來的identifier則是以regular expression來定義，由於第一位數不能為數字，因此須以[a-zA-Z]來開頭，而開頭至少要有一碼因此用+，再來後面的便是隨意數量的字母與數字，因此是[a-zA-Z0-9]*，而當符合條件時會觸發TOKEN_STRING(id,yytext)，如此以來到時候前綴便會顯示是id，後方則接著input。
constant則是相同的想法，constant分為三種，分別是integer、floating point和octal number，首先是integer的部分分為一位數字與兩位以上數字去進行處理，由於兩位以上數字的首位數字不能為0，因此為[1-9]+，個位數則隨意數字隨意數量因此接著[0-9]*，一位數字則是很明確的[0-9]；再來是floating point，分為三個部分，分別是小數點前為0後方只有一位小數、小數點前為0後方有兩位以上小數跟其他狀況，而會特別分為小數點前是否為0兩個種類是因為首位數字不可為0，而再細分為小數點後方為幾位小數是為了符合最後一碼不為0且須包含0.0的情形，因此分為兩種狀況；最後的octal number則為0開頭，後方接著數量隨意的數字0-7，因此是[0][0-7]+。
再來是scientific，共分為4種情形，分別由e前面為小數或是整數、e後方為0或是其他狀況這兩個條件來做區分，若e前方是小數則會有小數點且小數點後方要有至少一位數字，因此為[1-9]+[0-9]*[.][0-9]+，若為整數則只取小數點前方的部分；e後方則為了符合只有一個0的情形因此獨立成一個case。
string的部分則稍微麻煩一點，主要是要顧慮到雙引號內若有""出現則要視為"，否則一般的string的條件便是["][^\"]*["]，也就是雙引號內除了"外其他都能接收，之後便利用strncpy去掉頭尾的"後進行TOKEN_STRING即可；若有出現上述之特殊情形的條件則為["][^\"]*(\"\")+([^\"]*(\"\")*)*["]，也就是上述條件中間需要至少出現一""，而在""後可以有任意數量的其他符號與任意數量的""進行組合，處理方式則大同小異，去掉頭尾的"後用for loop去進行每一位元的解析，並以一type為char的變數tem去儲存上一個讀取的位元，若新讀取的位元與上一個讀取的位元皆為"且不為一開始的"之後所發生的情形，則不將新位元(第二個")進行儲存，並將tem清空避免重複讀取，若一切正常則將yytext中的位元儲存至一自訂的array(yy2)中，並更新tem為何，最後將yy2補上結束字元並丟進TOKEN_STRING即大功告成。
再來是comment，comment分為兩種，分別為/* */與//，而兩者皆以一DFA去實作，首先是//，分為INITIAL、COM1、COM2三個state，平時在INITIAL state，當吃到//時進入COM1並LIST，將結果記錄下來，COM1內則若接收到任何符號便可以進入COM2並LIST，之後讀到\n時便回到INTIAL並做平常換行會做的事；再來是/**/的部分，分為INITIAL與IN_COMMENT兩個state，平時在INITIAL state，當吃到/*時進入IN_COMMENT並LIST，IN_COMMENT內只要讀到任何符號便LIST，但仍停留在IN_COMMENT中，若讀到*/則LIST後回到INITIAL內。
最後是pseudocomment，無論是S或是T兩者的情形皆相同，唯一的不同只是S控制opt_src而T控制opt_tok而已，因此這裡只說明S的部分；平時在INITIAL state，當吃到//&S時進入COM3(T則為COM4)並LIST，在COM3(COM4)中若讀到+或-則LIST後將opt_src調為1(-則調為0)，並且跳至COM5(T則為COM6)，在COM5內讀到任何字元便都LIST，若讀到\n則回到INTIAL並做平常換行會做的事，即大功告成。

## What is the hardest you think in this project

最難的部份我認為是思考string那邊的regular expression，尤其是要處理當中有兩個"的情形

## Feedback to T.A.s

有一定的難度但也很有趣，思考各個的regular expression或是DFA有挑戰性但經過思考後仍然可以順利地做出。
