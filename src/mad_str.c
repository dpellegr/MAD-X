#include "madx.h"

// private globals

static char tmp_key[100*NAME_L];

// public interface

void
mystrcpy(struct char_array* target, char* source)
{
  /* string copy to char_array with size adjustment */
  int len = strlen(source);
  while (len > target->max) grow_char_array(target);
  strcpy(target->c, source);
}

char*
mycpy(char* out, const char* in)
  /* copies string, ends at any non-ascii character including 0 */
{
  int i;

  for (i=0; i<NAME_L-1 && in[i]>' ' && in[i]<='~'; i++)
    out[i] = in[i];

  out[i] = '\0';

  return out;
}

char*
mystrstr(char* string, const char* s)
  /* returns strstr for s, but only outside strings included
     in single or double quotes */
{
  char quote = ' '; /* only for the compiler */
  int toggle = 0, n = strlen(s);
  if (n == 0)  return NULL;
  while (*string != '\0')
  {
    if (toggle)
    {
      if (*string == quote) toggle = 0;
    }
    else if(*string == '\'' || *string == '\"')
    {
      quote = *string; toggle = 1;
    }
    else if (strncmp(string, s, n) == 0) return string;
    string++;
  }
  return NULL;
}

void
myrepl(const char* in, const char* out, char* string_in, char* string_out)
  /* replaces all occurrences of "in" in string_in by "out"
     in output string string_out */
{
  int n, add, l_in = strlen(in), l_out = strlen(out);
  char* cp;
  char tmp[8];
  while ((cp = strstr(string_in, in)) != NULL)
  {
    while (string_in != cp) *string_out++ = *string_in++;
    string_in += l_in;
    if (*out == '$')
    {
      n = get_variable(&out[1]);
      sprintf(tmp,"%d", n); add = strlen(tmp);
      strncpy(string_out, tmp, add);
      string_out += add;
    }
    else
    {
      strncpy(string_out, out, l_out);
      string_out += l_out;
    }
  }
  strcpy(string_out, string_in);
}

char*
mystrchr(char* string, char c)
  /* returns strchr for character c, but only outside strings included
     in single or double quotes */
{
  char quote = ' '; /* only for the compiler */
  int toggle = 0;
  while (*string != '\0')
  {
    if (toggle)
    {
      if (*string == quote) toggle = 0;
    }
    else if(*string == '\'' || *string == '\"')
    {
      quote = *string; toggle = 1;
    }
    else if (*string == c) return string;
    string++;
  }
  return NULL;
}

int
mysplit(char* buf, struct char_p_array* list)
{
  /* splits into tokens */
  int j;
  char* p;
  if ((p =strtok(buf, " \n")) == NULL) return 0;
  list->curr = 0;
  list->p[list->curr++] = p;
  while ((p = strtok(NULL, " \n")) != NULL)
  {
    if (list->curr == list->max) grow_char_p_array(list);
    list->p[list->curr++] = p;
  }
  /* remove '@' in strings */
  for (j = 0; j < list->curr; j++)
    if(*list->p[j] == '\"' || *list->p[j] == '\'') /* quote */
      replace(list->p[j], '@', ' ');

  return list->curr;
}

char*
buffer(const char* string)  /* replaced by permbuff */
{
  return permbuff(string);
}

char*
permbuff(const char* string)  /* string -> general buffer, returns address */
{
  int n, k = char_buff->ca[char_buff->curr-1]->curr;
  if (string == NULL)  return NULL;
  n = strlen(string)+1;
  if (k + n >= char_buff->ca[char_buff->curr-1]->max)
  {
    if (char_buff->curr == char_buff->max) grow_char_array_list(char_buff);
    char_buff->ca[char_buff->curr++] = new_char_array(CHAR_BUFF_SIZE);
    k = 0;
  }
  strcpy(&char_buff->ca[char_buff->curr-1]->c[k], string);
  char_buff->ca[char_buff->curr-1]->curr += n;
  return &char_buff->ca[char_buff->curr-1]->c[k];
}

char*
tmpbuff(const char* string)
  /* buffers string in a temporary (i.e. allocated) buffer */
  // aka strdup
{
  size_t len = strlen(string)+1;
  char* p = mycalloc_atomic("tmpbuff", len, sizeof *p);
  strcpy(p, string);
  return p;
}

void
conv_char(const char* string, struct int_array* tint)
  /*converts character string to integer array, using ascii code */
{
  int i, l = strlen(string);
  int n = (l < tint->max-1) ? l : tint->max-1;
  
  tint->i[0] = n;
  for (i = 0; i < n; i++) 
    tint->i[i+1] = (unsigned char) string[i];
}

void
stolower_nq(char* s)
  /* converts string to lower in place outside quotes */
{
  char *c = s;
  int j, toggle = 0;
  char quote = ' '; /* just to suit the compiler */
  for (j = 0; s[j]; j++)
  {
    if (toggle)
    {
      if (*c == quote) toggle = 0;
    }
    else if (*c == '\"' || *c == '\'')
    {
      toggle = 1; quote = *c;
    }
    else 
    {
      *c = (char) tolower((int) *c);
    }  
    c++;
  }
}

char*
strip(char* name)
  /* strip ':' and following off */
{
  char* p;
  assert(strlen(name) < sizeof tmp_key);
  strcpy(tmp_key, name);
  if ((p = strchr(tmp_key, ':')) != NULL) *p = '\0';
  return tmp_key;
}

int
supp_lt(char* inbuf, int flag)
  /* suppress leading, trailing blanks and replace some special char.s*/
{
  int l = strlen(inbuf), i, j;
  replace(inbuf, '\x9', ' '); /* tab */
  replace(inbuf, '\xd', ' '); /* Windows e-o-l */
  if (flag == 0)  replace(inbuf, '\n', ' '); /* e-o-l */
  supp_tb(inbuf); /* suppress trailing blanks */
  if ((l = strlen(inbuf)) > 0)
  {
    for (j = 0; j < l; j++) if (inbuf[j] != ' ') break; /* leading blanks */
    if (j > 0)
    {
      for (i = 0; i < l - j; i++) inbuf[i] = inbuf[i+j];
      inbuf[i] = '\0';
    }
  }
  return strlen(inbuf);
}

void
supp_mul_char(char c, char* string)
  /* reduces multiple occurrences of c in string to 1 occurrence */
{
  char* cp = string;
  int cnt = 0;
  while (*string != '\0')
  {
    if (*string != c)
    {
      *cp++ = *string; cnt = 0;
    }
    else if (cnt++ == 0) *cp++ = *string;
    string++;
  }
  *cp = '\0';
}

char*
supp_tb(char* string) /* suppress trailing blanks in string */
{
  int l = strlen(string), j;
  for (j = l-1; j >= 0; j--)
  {
    if (string[j] != ' ') break;
    string[j] = '\0';
  }
  return string;
}

int
zero_string(char* string) /* returns 1 if string defaults to '0', else 0 */
{
  int i, l = strlen(string);
  char c;
  for (i = 0; i < l; i++)
    if ((c = string[i]) != '0' && c != ' ' && c != '.') return 0;
  return 1;
}

int
is_token(char* pb, char* string, int slen)
{
  char* pbl = pb;
  if ((pbl == string || *(--pbl) == ' ')
      && (*(pb+slen) == '\0' || *(pb+slen) == ' '))  return 1;
  else return 0;
}

char*
join(char** it_list, int n)
  /* joins n character strings into one */
{
  int j;
  *c_join->c = '\0';
  for (j = 0; j < n; j++) strcat(c_join->c, it_list[j]);
  return c_join->c;
}

char*
join_b(char** it_list, int n)
  /* joins n character strings into one, blank separated */
{
  char* target;
  int j, k = 0;
  target = c_join->c;
  for (j = 0; j < n; j++)
  {
    strcpy(&target[k], it_list[j]);
    k += strlen(it_list[j]);
    target[k++] = ' ';
  }
  target[k] = '\0';
  return target;
}

char
next_non_blank(char* string)
  /* returns next non-blank in string outside quotes, else blank */
{
  int i, toggle = 0, l = strlen(string);
  char quote = ' ';
  for (i = 0; i < l; i++)
  {
    if (toggle)
    {
      if (string[i] == quote)  toggle = 0;
    }
    else if (string[i] == '\'' || string[i] == '\"')
    {
      quote = string[i]; toggle = 1;
    }
    else if (string[i] != ' ')  return string[i];
  }
  return ' ';
}

int
next_non_blank_pos(char* string)
  /* returns position of next non-blank in string outside quotes, else -1 */
{
  int i, toggle = 0, l = strlen(string);
  char quote = ' ';
  for (i = 0; i < l; i++)
  {
    if (toggle)
    {
      if (string[i] == quote)  toggle = 0;
    }
    else if (string[i] == '\'' || string[i] == '\"')
    {
      quote = string[i]; toggle = 1;
    }
    else if (string[i] != ' ')  return i;
  }
  return -1;
}

char*
noquote(char* string)
{
  char* c = string;
  char* d = c;
  char k;
  if (string != NULL)
  {
    k = *c;
    if (k == '\"' || k == '\'')
    {
      d++;
      while (*d != k) *c++ = *d++;
      *c = '\0';
    }
  }
  return string;
}

char*
slash_to_bkslash(char* string)
{
#ifdef _WIN32
  for(char *s=string; s && (s=strchr(s,'/')); *s='\\') ;
#endif
  return string;
}

int
quote_level(char* string, char* send)
{
/* returns the level count of quotation marks " and ' inside string between */
/* start of string and send */
  int level = 0;
  char* p;
  char c = ' ';
  for (p = string; p < send; p++)
  {
    if (level == 0)
    {
      if (*p == '\"' || *p == '\'')
      {
        c = *p; level++;
      }
    }
    else if(*p == c) level--;
  }
  return level;
}

#if 0 // not used...
static int
remove_colon(char** toks, int number, int start)
  /* removes colon behind declarative part for MAD-8 compatibility */
{
  int i, k = start;
  for (i = start; i < number; i++)
    if (*toks[i] != ':') toks[k++] = toks[i];
  return k;
}
#endif

int
square_to_colon(char* string)
  /* sets occurrence count behind colon, possibly replacing [] */
  // LD: this function assume that there is enough room to concatenate ':1' at the end!!
{
  char* t;

  if ((t = strchr(string, '[')) == NULL)
    strcat(string, ":1"); // unsafe!
  else {
    *t = ':';
    if ((t = strchr(t+1, ']')) == NULL) return 0;
    else *t = '\0';
  }

  return strlen(string);
}

