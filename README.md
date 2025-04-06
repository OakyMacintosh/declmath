# MathAsScripting
Math as a Scripting thing (the brain is your interpreter > (see -> #{math}; then interpret(it)))

## Introduction
Okay...you're in a math class and you're a programmer, but, you think math as a scripting language... creating variables in your calculations.... <br/>

$$
 x = 13;
 \frac{x - \sqrt{13^3}}{15}
$$

but...you can't just think it as a language with all those formations and other things.... <br/>
But, **i developed a solution**...

**DeclMath**
you can turn this: <br/>

$$
x = 12; \sqrt{x}
$$

into this ...:

```declmath
x = 12
root(x)
```

Run the same code on a computer and in your mind, with the MathAsScripting book!

### Scripting with **Math**
Math in some cases is considered a programming language, but it is less consize and doesn't use any common programming concepts (except variables and functions), but during math classes i structured a little grammar and the basic language concepts adapted to common math concepts

like, the baskara formula can be reformated from this: <br/>

$$
  x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

<br/>

to this: <br/>

```declmath
x = frac(-b +/- root(b^2 - 4ac)2a)
await('c', 'a' and 'b')
```

### Language variations
The `DeclMath` language can variate depending on the calculator's (a human or a machine) main language, in human cases you can declare the variation of your choice: <br/>
```declmath
#lang * 'pt_br' # for Portugues do Brasil
#lang * 'pt_pt' # for Portugues de Portugal
#lang * 'en' # for American English
#lang * 'en' -> __british__ # for British English
#lang * 'jp' -> __piing__ # For ジャポネス・ピング
```

#### Japonese variation **only**
The words in the japonese form of declmath aren't fluent translations, it can't variate.
```declmath
#lang * 'jp' -> __piing__

# DeclMathの日本語例
ルート(\32)
もし根が32と同じであれば、次の操作を行います。:
      印刷(output)
終了
```

**Translated to japonese using Microsoft Translate**

## License
Obviously i'm using the MIT License.
