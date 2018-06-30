
#include "c:\ruby\lib\ruby\1.8\i386-m~1\ruby.h"
#include <stdlib.h> // calloc,free

#include "image24.h"

#include "types.h"

// PORT notes:
//
//   All code beyond the DEFINITIONS section is the same between all Image*.c. The
//   only difference is that all references to the "struct image" is named Image1,
//   Image4, etc. in their respective files.

//   Image1.c and Image4.c share similar definitions as they pack multiple pixels
//     per internal bucket.
//   Image8.c and Image16.c are very similar in that they define one pixel per
//     internal bucket but differ in the bucket size.
//   Image24.c has one pixel per bucket but that bucket is a struct rather than a
//     basic type.

//*********************** DEFINITIONS ****************************************

//
//  ONLY NEED TO PORT THIS SECTION
//

// Pixel we pass back and forth with ruby is simply a FIXNUM in range 0 .. 2^24-1

typedef INT32 Pixel;

// Pixel representation we store in memory:

// PORT AS NEEDED
typedef struct pix {BYTE r,g,b;} InternalBucket; // Image24.c we store 1 pixel in a 3 byte bucket

typedef UINT32 PolyId;

typedef struct polyMap {
    VALUE  eightNeighs;
    PolyId totalPolys;
	INT32 rows;
	INT32 cols;
	PolyId **rowsOfPolyIds;
} PolyMap;

typedef struct image {
  PolyMap* polyMap;
  INT32 rows;
  INT32 cols;
  InternalBucket  **rowsOfPixelBuckets;
} Image24;

// PORT AS NEEDED
inline
static INT32 bucketNumber(INT32 col)
{
	return col;  // 1 pixel per bucket
}

// PORT AS NEEDED
inline
static INT32 sliceNumber(INT32 col)
{
	return 0;  // 1 pixel per bucket
}


// PORT AS NEEDED
inline
static InternalBucket internal(InternalBucket currBucket, INT32 sliceNum, Pixel newPix)
{
	InternalBucket bucket;

	bucket.r = (newPix >> 16) & 255;
	bucket.g = (newPix >> 8) & 255;
	bucket.b = (newPix) & 255;

	return bucket;
}

// PORT AS NEEDED
inline
static Pixel external(InternalBucket bucket, INT32 sliceNum)
{
	return (Pixel) (bucket.r << 16) | (bucket.g << 8) | (bucket.b);
}

//  NO NEED TO PORT BEYOND THIS SECTION

//***********************  PolyMap *******************************************

static PolyMap* newPolyMap()
{
	void* memBlk = calloc(1,sizeof(PolyMap));

	if (memBlk == NULL)
	  rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (1.1)");

	return memBlk;
}

static void freePolyMapRows(PolyMap* pmap)
{
  INT32 r;

  if ((pmap) && (pmap->rowsOfPolyIds))
  {
    for (r = 0; r < pmap->rows; r++)
      if (pmap->rowsOfPolyIds[r])
        free(pmap->rowsOfPolyIds[r]);
    free(pmap->rowsOfPolyIds);
  }
}

static void freePolyMap(PolyMap* pmap)
{
  if (pmap)
  {
    if (pmap->rowsOfPolyIds)
      freePolyMapRows(pmap);

    free(pmap);
  }
}

static void sizePolyMap(PolyMap* pmap, INT32 rows, INT32 cols)
{
	INT32 r;

	pmap->rows = rows;
	pmap->cols = cols;

	if (pmap->rowsOfPolyIds)
	  freePolyMapRows(pmap);

    pmap->rowsOfPolyIds = calloc(sizeof(PolyId*),rows);

	if (pmap->rowsOfPolyIds == NULL)
	  rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (2.1)");

    for (r = 0; r < rows; r++)
    {
      pmap->rowsOfPolyIds[r] = calloc(sizeof(PolyId),cols);

	  if (pmap->rowsOfPolyIds[r] == NULL)
	    rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (2.2)");
    }
}

static PolyId pmapGetP(PolyMap* p, INT32 r, INT32 c)
{
	return p->rowsOfPolyIds[r][c];
}

static void pmapSetP(PolyMap* p, INT32 r, INT32 c, PolyId pnum)
{
	p->rowsOfPolyIds[r][c] = pnum;
}

//***********************  Image24 *******************************************

static VALUE cImage24 = Qnil;

static void freeRowsOfPixels(Image24* image)
{
  INT32 r;

  if ((image) && (image->rowsOfPixelBuckets))
  {
    for (r = 0; r < image->rows; r++)
      if (image->rowsOfPixelBuckets[r])
        free(image->rowsOfPixelBuckets[r]);
     free(image->rowsOfPixelBuckets);
  }
}

static void Image24_free(Image24* image)
{
  if (image)
  {
    freeRowsOfPixels(image);
    if (image->polyMap)
      freePolyMap(image->polyMap);

    free(image);
  }
}

inline
static void setBucket(Image24* i, INT32 r, INT32 c, InternalBucket b)
{
	i->rowsOfPixelBuckets[r][bucketNumber(c)] = b;
}

inline
static InternalBucket getBucket(Image24* i, INT32 r, INT32 c)
{
	return i->rowsOfPixelBuckets[r][bucketNumber(c)];
}

inline
static void imageSetP(Image24* i, INT32 r, INT32 c, Pixel pixValue)
{
  setBucket(i,r,c,internal(getBucket(i,r,c),sliceNumber(c),pixValue));
}

inline
static Pixel imageGetP(Image24* i, INT32 r, INT32 c)
{
  return external(getBucket(i,r,c),sliceNumber(c));
}

// NO MORE PORTING NEEDED BEYOND THIS POINT PER IMAGE*.C

static VALUE t_specify(VALUE self, VALUE rowsFixedNum, VALUE colsFixedNum)
{
  VALUE imageObj = rb_iv_get(self,"@image");

  INT32 r, rows, cols;
  Image24* image;

  Data_Get_Struct(imageObj,Image24,image);

  image->rows = FIX2INT(rowsFixedNum);
  image->cols = FIX2INT(colsFixedNum);

  if (image->rowsOfPixelBuckets)
    freeRowsOfPixels(image);

  rows = image->rows;
  cols = image->cols;

  image->rowsOfPixelBuckets = calloc(sizeof(InternalBucket**), rows);

  if (image->rowsOfPixelBuckets == NULL)
    rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (3.1)");

  for (r = 0; r < rows; r++)
  {
	  image->rowsOfPixelBuckets[r] = calloc(sizeof(InternalBucket*), bucketNumber(cols)+1);

      if (image->rowsOfPixelBuckets[r] == NULL)
        rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (3.2)");
  }

  return Qnil;
}

static VALUE t_init(VALUE self, VALUE rows, VALUE cols)
{
  Image24* image = calloc(1,sizeof(Image24));

  if (image == NULL)
    rb_raise(rb_eRuntimeError,"Image24 cannot find enough/correct memory configuration for internal structures (4)");

  rb_iv_set(self,"@image",Data_Wrap_Struct(cImage24,0,Image24_free,image));
  rb_iv_set(self,"@areas",rb_ary_new());
  rb_iv_set(self,"@perims",rb_ary_new());
  rb_iv_set(self,"@legend",rb_hash_new());
  rb_iv_set(self,"@palette",rb_ary_new());
  rb_iv_set(self,"@title",rb_str_new2("Untitled"));
  rb_iv_set(self,"@polyAreas",Qnil);
  rb_iv_set(self,"@polyPerims",Qnil);
  rb_iv_set(self,"@polyCovers",Qnil);
  rb_iv_set(self,"@perim",Qnil);

  t_specify(self, rows, cols);

  return Qnil;
}

static VALUE t_getCell(VALUE self, VALUE row, VALUE col)
{
  if (RTEST(self) && FIXNUM_P(row) && FIXNUM_P(col))
  {
    VALUE imageObj = rb_iv_get(self,"@image");

    Image24* image;

    Data_Get_Struct(imageObj,Image24,image);

    return INT2FIX(imageGetP(image, FIX2INT(row), FIX2INT(col)));
  }
  else
    rb_raise(rb_eRuntimeError,"Image24.getCell() has received faulty arguments.");

  return Qnil;
}

static VALUE t_setCell(VALUE self, VALUE row, VALUE col, VALUE pixelValue)
{
  if (RTEST(self) && FIXNUM_P(row) && FIXNUM_P(col) && FIXNUM_P(pixelValue))
  {
    VALUE imageObj = rb_iv_get(self,"@image");

    Image24* image;

    Data_Get_Struct(imageObj,Image24,image);

    imageSetP(image, FIX2INT(row), FIX2INT(col), (Pixel) FIX2INT(pixelValue));
  }
  else
    rb_raise(rb_eRuntimeError,"Image24.setCell() has received faulty arguments.");

  return Qnil;
}

static VALUE t_areas(VALUE self)
{
  VALUE imageObj;
  VALUE areasObj;
  Image24* image;
  INT32 r,c,rows,cols;

  if (!RTEST(self)) return INT2FIX(0);

  imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  areasObj = rb_iv_get(self,"@areas");

  if (!RARRAY(areasObj)->len)
  {
    rows = image->rows;
    cols = image->cols;
    for (r = 0; r < rows; r++)
    {
      for (c = 0; c < cols; c++)
      {
        Pixel pixelValue = imageGetP(image,r,c);
        VALUE finalVal;
        VALUE entry = rb_ary_entry(areasObj,(long)pixelValue);

        if (!RTEST(entry))
          finalVal = INT2FIX(1);
        else
          finalVal = INT2FIX( FIX2INT(entry) + 1);

        rb_ary_store(areasObj,(long)pixelValue,finalVal);
      }
    }

  }

  return areasObj;
}

static VALUE t_perimeters(VALUE self)
{
  VALUE imageObj;
  VALUE array;
  Image24* image;
  INT32 r,c,rows,cols;

  if (!RTEST(self)) return Qnil;

  imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  array = rb_iv_get(self,"@perims");

  if (!RARRAY(array)->len)
  {
	  rows = image->rows;
	  cols = image->cols;

      for (r = 0; r < rows; r++)
        for (c = 0; c < cols; c++)
        {
          VALUE finalVal,entry;
          INT32 perimCount = 0;
          Pixel center = imageGetP(image,r,c);

          if ((r == 0) || (imageGetP(image,r-1,c) != center))
            perimCount++;
          if ((r == rows-1) || (imageGetP(image,r+1,c) != center))
            perimCount++;
          if ((c == 0) || (imageGetP(image,r,c-1) != center))
            perimCount++;
          if ((c == cols-1) || (imageGetP(image,r,c+1) != center))
            perimCount++;

          if (perimCount)
          {
		    entry = rb_ary_entry(array,(long)center);

		    if (!RTEST(entry))
		      finalVal = INT2FIX(perimCount);
		    else
		      finalVal = INT2FIX( FIX2INT(entry) + perimCount);

		    rb_ary_store(array,(long)center,finalVal);
	      }
        }
  }

  return array;

}

static VALUE t_area(VALUE self)
{
  VALUE imageObj;
  Image24* image;

  if (!RTEST(self)) return INT2FIX(0);

  imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  return INT2FIX(image->rows * image->cols);
}

static VALUE t_perimeter(VALUE self)
{
  VALUE perim = rb_iv_get(self,"@perim");

  if (perim == Qnil)
  {
    INT32 r,c,rows,cols;
    INT32 count;
    Image24* image;

    VALUE imageObj = rb_iv_get(self,"@image");

    Data_Get_Struct(imageObj,Image24,image);

    rows = image->rows;
    cols = image->cols;

    count = 0;

    // from lower left (0,0) to upper right
    for (r = 0; r < rows; r++)
      for (c = 0; c < cols; c++)
      {
          Pixel center = imageGetP(image,r,c);
		  if (r != 0)  // do I have a shared edge to my south?
		  {
			  if (center != imageGetP(image,r-1,c))
			    count++;
		  }
		  if (c != cols-1)  // do I have a shared edge to my right?
		  {
			  if (center != imageGetP(image,r,c+1))
			    count++;
		  }
	  }

	count += 2*rows + 2*cols;  // add outside edges

    perim = INT2FIX(count);

    rb_iv_set(self,"@perim",perim);
  }

  return perim;
}

static VALUE t_rows(VALUE self)
{
  VALUE imageObj;
  Image24* image;

  if (!RTEST(self)) return INT2FIX(0);

  imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  return INT2FIX(image->rows);
}

static VALUE t_cols(VALUE self)
{

  VALUE imageObj;
  Image24* image;

  if (!RTEST(self)) return INT2FIX(0);

  imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  return INT2FIX(image->cols);
}

static VALUE t_classesPresent(VALUE self)
{
  VALUE array = t_areas(self);

  INT32 total = 0;

  INT32 len = RARRAY(array)->len;
  INT32 i;
  for (i = 0; i < len; i++)
  {
    VALUE entry = rb_ary_entry(array,i);
    if (entry != Qnil)
      total++;
  }

  return INT2FIX(total);
}

static VALUE t_legend(VALUE self)
{
  return rb_iv_get(self,"@legend");
}

static VALUE t_palette(VALUE self)
{
  return rb_iv_get(self,"@palette");
}

static VALUE t_title(VALUE self)
{
  return rb_iv_get(self,"@title");
}

static VALUE t_setTitle(VALUE self,VALUE title)
{
  return rb_iv_set(self,"@title",title);
}

static VALUE t_each(VALUE self)
{
  VALUE imageObj = rb_iv_get(self,"@image");

  INT32 r,c,rows,cols;

  Image24* image;

  Data_Get_Struct(imageObj,Image24,image);

  rows = image->rows;
  cols = image->cols;

  for (r = 0; r < rows; r++)
  {
    for (c = 0; c < cols; c++)
    {
      Pixel pixelValue = imageGetP(image,r,c);
      rb_yield(INT2FIX(pixelValue));
    }
  }

  return Qnil;
}

// 1) could rewrite as sliding window to reduce imageGetP() lookups.
//      Right now it does about 5 lookups per pixel. It could just do one.

static VALUE t_each5(VALUE self)
{
  INT32 r, c, rows, cols;
  VALUE center, north, south, east, west;
  Image24* image;

  VALUE imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  rows = image->rows;
  cols = image->cols;

  for (r=0; r < rows; r++)
  {
    for (c=0; c < cols; c++)
    {
      center = INT2FIX(imageGetP(image,r,c));
      if (r < rows-1)
        north = INT2FIX(imageGetP(image,r+1,c));
      else
        north = Qnil;
      if (r > 0)
        south = INT2FIX(imageGetP(image,r-1,c));
      else
        south = Qnil;
      if (c > 0)
        west = INT2FIX(imageGetP(image,r,c-1));
      else
        west = Qnil;
      if (c < cols-1)
        east = INT2FIX(imageGetP(image,r,c+1));
      else
        east = Qnil;

      rb_yield(rb_ary_new3(5,center,north,south,east,west));
    }
  }

  return Qnil;
}

#if 0

// this method as of release 1.19 is 3% slower than brute access method later

const int DIR_RIGHT = 1;
const int DIR_LEFT = -1;

static VALUE t_each9(VALUE self)
{
  INT32 r,c,rows,cols;
  UINT32 p,maxPixels;
  VALUE ctr, nw, n, ne, w, e, sw, s, se;
  int direction;

  Image24* image;

  VALUE imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  direction = DIR_RIGHT;

  rows = image->rows;
  cols = image->cols;

  r = rows-1;
  c = 0;

  nw = Qnil;
  n  = Qnil;
  ne  = Qnil;
  w  = Qnil;
  ctr = INT2FIX(imageGetP(image,r,0));
  e = cols > 1 ? INT2FIX(imageGetP(image,r,1)) : Qnil;
  sw = Qnil;
  if (rows > 1)
  {
    s = INT2FIX(imageGetP(image,r-1,0));
    se = cols > 1 ? INT2FIX(imageGetP(image,r-1,1)) : Qnil;
  }
  else  // only one row
  {
    s = Qnil;
    se = Qnil;
  }

  maxPixels = rows*cols;
  for (p = 0; p < maxPixels; p++)
  {
    rb_yield(rb_ary_new3(9,ctr,nw,n,ne,w,e,sw,s,se));

    if (direction == DIR_RIGHT)
    {
      c++;
      if (c == cols)  // did we just pass edge of image?
      {
        c = cols-1;  // go down a row and start at right edge
        r--;
        if (r > 0)
        {
          nw = w;
          n = ctr;
          ne = e;
          w = sw;
          ctr = s;
          e = se;
          sw = c > 0 ? INT2FIX(imageGetP(image,r-1,c-1)) : Qnil;
          s = INT2FIX(imageGetP(image,r-1,c));
          se = Qnil;
        }
        else if (r == 0) // can't slide down any farther
        {
          nw = w;
          n = ctr;
          ne = e;
          w = sw;
          ctr = s;
          e = se;
          sw = Qnil;
          s = Qnil;
          se = Qnil;
		}
		else // r < 0 : done
		{
          nw = Qnil;
          n = Qnil;
          ne = Qnil;
          w = Qnil;
          ctr = Qnil;
          e = Qnil;
          sw = Qnil;
          s = Qnil;
          se = Qnil;
		}

        direction = DIR_LEFT;
      }
      else  // col in bounds
      {
        if (c < cols-1)
        {
          nw = n;
          n = ne;
          ne = r < rows-1 ? INT2FIX(imageGetP(image,r+1,c+1)) : Qnil;
          w = ctr;
          ctr = e;
          e = INT2FIX(imageGetP(image,r,c+1));
          sw = s;
          s = se;
          se = r > 0 ? INT2FIX(imageGetP(image,r-1,c+1)) : Qnil;
        }
        else  // col == cols-1
        {
          nw = n;
          n = ne;
          ne = Qnil;
          w = ctr;
          ctr = e;
          e = Qnil;
          sw = s;
          s = se;
          se = Qnil;
		}
      }
    }
    else // direction == DIR_LEFT
    {
      c--;
      if (c == -1)  // did we just pass edge of image?
      {
        c = 0;  // go down a row and start at left edge
        r--;
        if (r > 0)
        {
          nw = w;
          n = ctr;
          ne = e;
          w = sw;
          ctr = s;
          e = se;
          sw = Qnil;
          s = INT2FIX(imageGetP(image,r-1,c));
          se = c < cols-1 ? INT2FIX(imageGetP(image,r-1,c+1)) : Qnil;
        }
        else if (r == 0) // can't slide down
        {
          nw = w;
          n = ctr;
          ne = e;
          w = sw;
          ctr = s;
          e = se;
          sw = Qnil;
          s = Qnil;
          se = Qnil;
		}
		else // r < 0 : we're done
		{
          nw = Qnil;
          n = Qnil;
          ne = Qnil;
          w = Qnil;
          ctr = Qnil;
          e = Qnil;
          sw = Qnil;
          s = Qnil;
          se = Qnil;
		}

        direction = DIR_RIGHT;
      }
      else  // col in bounds
      {
        if (c > 0)
        {
          ne = n;
          n = nw;
          nw = r < rows-1 ? INT2FIX(imageGetP(image,r+1,c-1)) : Qnil;
          e = ctr;
          ctr = w;
          w = INT2FIX(imageGetP(image,r,c-1));
          se = s;
          s = sw;
          sw = r > 0 ? INT2FIX(imageGetP(image,r-1,c-1)) : Qnil;
        }
        else  // col == 0
        {
          ne = n;
          n = nw;
          nw = Qnil;
          e = ctr;
          ctr = w;
          w = Qnil;
          se = s;
          s = sw;
          sw = Qnil;
		}
      }
    }
  }
  return Qnil;
}

#else

static VALUE t_each9(VALUE self)
{
  INT32 r,c,rows,cols;
  VALUE ctr,nw,n,ne,w,e,sw,s,se;
  Image24* image;

  VALUE imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  rows = image->rows;
  cols = image->cols;

  for (r=0; r < rows; r++)
  {
    for (c=0; c < cols; c++)
    {
      ctr = INT2FIX(imageGetP(image,r,c));
      if (r < rows-1)
      {
        n = INT2FIX(imageGetP(image,r+1,c));
        if (c == 0)
        {
          nw = Qnil;
          ne = INT2FIX(imageGetP(image,r+1,c+1));
        }
        else if (c == cols-1)
        {
          ne = Qnil;
          nw = INT2FIX(imageGetP(image,r+1,c-1));
        }
        else
        {
          ne = INT2FIX(imageGetP(image,r+1,c+1));
          nw = INT2FIX(imageGetP(image,r+1,c-1));
        }
      }
      else
      {
        nw = Qnil;
        n = Qnil;
        ne = Qnil;
      }
      if (r > 0)
      {
        s = INT2FIX(imageGetP(image,r-1,c));
        if (c == 0)
        {
          sw = Qnil;
          se = INT2FIX(imageGetP(image,r-1,c+1));
        }
        else if (c == cols-1)
        {
          se = Qnil;
          sw = INT2FIX(imageGetP(image,r-1,c-1));
        }
        else
        {
          se = INT2FIX(imageGetP(image,r-1,c+1));
          sw = INT2FIX(imageGetP(image,r-1,c-1));
        }
      }
      else
      {
        sw = Qnil;
        s = Qnil;
        se = Qnil;
      }
      if (c > 0)
      {
        w = INT2FIX(imageGetP(image,r,c-1));
        if (r == 0)
        {
          nw = INT2FIX(imageGetP(image,r+1,c-1));
          sw = Qnil;
        }
        else if (r == rows-1)
        {
          nw = Qnil;
          sw = INT2FIX(imageGetP(image,r-1,c-1));
        }
        else
        {
          nw = INT2FIX(imageGetP(image,r+1,c-1));
          sw = INT2FIX(imageGetP(image,r-1,c-1));
        }
      }
      else
      {
        nw = Qnil;
        w = Qnil;
        sw = Qnil;
      }
      if (c < cols-1)
      {
        e = INT2FIX(imageGetP(image,r,c+1));
        if (r == 0)
        {
          ne = INT2FIX(imageGetP(image,r+1,c+1));
          se = Qnil;
        }
        else if (r == rows-1)
        {
          ne = Qnil;
          se = INT2FIX(imageGetP(image,r-1,c+1));
        }
        else
        {
          ne = INT2FIX(imageGetP(image,r+1,c+1));
          se = INT2FIX(imageGetP(image,r-1,c+1));
        }
      }
      else
      {
        ne = Qnil;
        e = Qnil;
        se = Qnil;
      }

      rb_yield(rb_ary_new3(9,ctr,nw,n,ne,w,e,sw,s,se));
    }
  }

  return Qnil;
}

#endif

static VALUE stackNew()
{
  return rb_ary_new();
}

static void stackReset(VALUE stack)
{
  rb_ary_clear(stack);
}

static void stackPush(VALUE stack, INT32 num)
{
  rb_ary_push(stack,INT2FIX(num));
}

static INT32 stackPop(VALUE stack)
{
  return FIX2INT(rb_ary_pop(stack));
}

static int stackEmpty(VALUE stack)
{
  return RARRAY(stack)->len == 0;
}

static void makePolyMap(VALUE self, Image24* image, VALUE eightNeighbors)
{
  PolyMap* polyMap;
  INT32 lastRow, lastCol, startRow, startCol,
         row, col, startRun, endRun, right, left, c;
  int prevRowComplete, nextRowComplete;
  Pixel desiredCover;
  VALUE stack;

  if (image->polyMap)
    freePolyMap(image->polyMap);

  rb_iv_set(self,"@polyAreas",Qnil);   // invalidate existing poly areas
  rb_iv_set(self,"@polyPerims",Qnil);  // invalidate existing poly perims
  rb_iv_set(self,"@polyCovers",Qnil);  // invalidate existing poly covers

  image->polyMap = newPolyMap();
  polyMap = image->polyMap;

  polyMap->eightNeighs = eightNeighbors;

  polyMap->totalPolys = 0;

  sizePolyMap(polyMap,image->rows,image->cols);  // and initially all zeros

  lastRow = image->rows - 1;
  lastCol = image->cols - 1;

#if 0
  printf("Map\n");
  for (startRow=0; startRow<=lastRow; startRow++)
  {
    for (startCol=0; startCol<=lastCol; startCol++)
      printf(" %2d", (int)imageGetP(image,startRow,startCol));
    printf("\n");
  }
#endif

  stack = stackNew();
  for (startRow=0; startRow<=lastRow; startRow++)
  {
    for (startCol=0; startCol<=lastCol; startCol++)
    {
      if (pmapGetP(polyMap,startRow,startCol) == 0)
      {
        polyMap->totalPolys++;
        desiredCover = imageGetP(image,startRow,startCol);

        stackReset(stack);
        stackPush(stack,startRow);
        stackPush(stack,startCol);
        while (!stackEmpty(stack))
        {
          col = stackPop(stack);
          row = stackPop(stack);

          // fill self
          pmapSetP(polyMap,row,col,polyMap->totalPolys);

          // fill left
          left = col-1;
          while ((left >= 0) &&
                 (imageGetP(image,row,left) == desiredCover))
          {
            pmapSetP(polyMap,row,left,polyMap->totalPolys);
            left--;
          }
          if (eightNeighbors == Qtrue)
          {
            if (left < 0)
              left++;
          }
          else // four neighbors
            left++;

          // fill right
          right = col+1;
          while ((right <= lastCol) &&
                 (imageGetP(image,row,right) == desiredCover))
          {
            pmapSetP(polyMap,row,right,polyMap->totalPolys);
            right++;
          }
          if (eightNeighbors == Qtrue)
          {
            if (right > lastCol)
              right--;
          }
          else // four neighbors
            right--;

          // see if row+1 and row-1 have been completed: if no then push()

          prevRowComplete = 1;
          if (row-1 >= 0)
            for (c = left; c <= right; c++)
              if ((pmapGetP(polyMap,row-1,c) == 0) &&
                  (imageGetP(image,row-1,c) == desiredCover))
              {
                prevRowComplete = 0;
                break;
              }
          if (!prevRowComplete)
          {
            // push right endpoint of each subspan
            startRun = left;
            while (startRun <= right)
            {
              // find start of a run
              while ((startRun <= right) &&
                     ( (imageGetP(image,row-1,startRun) != desiredCover) ||
                       (pmapGetP(polyMap,row-1,startRun) != 0)
                     )
                    )
                startRun++;

              // find end of same run
              endRun = startRun;

              while ((endRun <= right) &&
                     ( (imageGetP(image,row-1,endRun) == desiredCover) &&
                       (pmapGetP(polyMap,row-1,endRun) == 0)
                     )
                    )
                endRun++;
              endRun--;

              if (startRun <= right)
              {
                stackPush(stack,row-1);
                stackPush(stack,endRun);
              }

              startRun = endRun + 1;
            }
          }

          nextRowComplete = 1;
          if (row+1 <= lastRow)
            for (c = left; c <= right; c++)
              if ((pmapGetP(polyMap,row+1,c) == 0) &&
                  (imageGetP(image,row+1,c) == desiredCover))
              {
                nextRowComplete = 0;
                break;
              }
          if (!nextRowComplete)
          {
            // push right endpoint of each subspan
            startRun = left;
            while (startRun <= right)
            {
              // find start of a run
              while ((startRun <= right) &&
                     ( (imageGetP(image,row+1,startRun) != desiredCover) ||
                       (pmapGetP(polyMap,row+1,startRun) != 0)
                     )
                    )
                startRun++;

              // find end of same run
              endRun = startRun;

              while ((endRun <= right) &&
                     ( (imageGetP(image,row+1,endRun) == desiredCover) &&
                       (pmapGetP(polyMap,row+1,endRun) == 0)
                     )
                    )
                endRun++;
              endRun--;

              if (startRun <= right)
              {
                stackPush(stack,row+1);
                stackPush(stack,endRun);
              }

              startRun = endRun + 1;
            }
          }
        }
      }
    }
  }
#if 0
  printf("PolyMap\n");
  for (startRow = 0; startRow <= lastRow; startRow++)
  {
	  for (startCol = 0; startCol <= lastCol; startCol++)
		  printf(" %2d",(int)pmapGetP(polyMap,startRow,startCol));
	  printf("\n");
  }
#endif
}

static VALUE t_polyCount(VALUE self, VALUE eightNeighbors)
{
  Image24* image;

  VALUE imageObj = rb_iv_get(self,"@image");

  Data_Get_Struct(imageObj,Image24,image);

  if ((!image->polyMap) || (image->polyMap->eightNeighs != eightNeighbors))
	  makePolyMap(self,image,eightNeighbors);

  return INT2FIX(image->polyMap->totalPolys);
}

static VALUE t_polyAreas(VALUE self, VALUE eightNeighbors)
{
  Image24* image;

  PolyMap* polyMap;

  INT32 r,c,rows,cols;

  VALUE array, imageObj;

  imageObj = rb_iv_get(self,"@image");
  Data_Get_Struct(imageObj,Image24,image);

  if ((!image->polyMap) || (image->polyMap->eightNeighs != eightNeighbors))
	  makePolyMap(self,image,eightNeighbors);

  polyMap = image->polyMap;

  array = rb_iv_get(self,"@polyAreas");
  if (array == Qnil)
  {
	  array = rb_ary_new();
	  rb_iv_set(self,"@polyAreas",array);

	  rows = polyMap->rows;
	  cols = polyMap->cols;

      for (r = 0; r < rows; r++)
        for (c = 0; c < cols; c++)
        {
          VALUE finalVal,entry;
          PolyId polyNum = pmapGetP(polyMap,r,c);

          entry = rb_ary_entry(array,(long)polyNum);

          if (!RTEST(entry))
            finalVal = INT2FIX(1);
          else
            finalVal = INT2FIX( FIX2INT(entry) + 1);

          rb_ary_store(array,(long)polyNum,finalVal);
		}
  }

  return array;
}

static VALUE t_polyPerims(VALUE self, VALUE eightNeighbors)
{
  Image24* image;

  PolyMap* polyMap;

  VALUE array, imageObj;

  INT32 r,c,rows,cols;

  imageObj = rb_iv_get(self,"@image");
  Data_Get_Struct(imageObj,Image24,image);

  if ((!image->polyMap) || (image->polyMap->eightNeighs != eightNeighbors))
	  makePolyMap(self,image,eightNeighbors);

  polyMap = image->polyMap;

  array = rb_iv_get(self,"@polyPerims");
  if (array == Qnil)
  {
	  array = rb_ary_new();
	  rb_iv_set(self,"@polyPerims",array);

	  rows = polyMap->rows;
	  cols = polyMap->cols;

      for (r = 0; r < rows; r++)
        for (c = 0; c < cols; c++)
        {
          VALUE finalVal,entry;
          INT32 perimCount = 0;
          PolyId polyNum = pmapGetP(polyMap,r,c);

          if ((r == 0) || (pmapGetP(polyMap,r-1,c) != polyNum))
            perimCount++;
          if ((r == rows-1) || (pmapGetP(polyMap,r+1,c) != polyNum))
            perimCount++;
          if ((c == 0) || (pmapGetP(polyMap,r,c-1) != polyNum))
            perimCount++;
          if ((c == cols-1) || (pmapGetP(polyMap,r,c+1) != polyNum))
            perimCount++;

          if (perimCount)
          {
		    entry = rb_ary_entry(array,(long)polyNum);

		    if (!RTEST(entry))
		      finalVal = INT2FIX(perimCount);
		    else
		      finalVal = INT2FIX( FIX2INT(entry) + perimCount);

		    rb_ary_store(array,(long)polyNum,finalVal);
	      }
        }
  }

  return array;
}

static VALUE t_polyClasses(VALUE self, VALUE eightNeighbors)
{
  Image24* image;

  PolyMap* polyMap;

  VALUE array, imageObj;

  INT32 r, c, rows, cols;

  imageObj = rb_iv_get(self,"@image");
  Data_Get_Struct(imageObj,Image24,image);

  if ((!image->polyMap) || (image->polyMap->eightNeighs != eightNeighbors))
	  makePolyMap(self,image,eightNeighbors);

  polyMap = image->polyMap;

  array = rb_iv_get(self,"@polyCovers");
  if (array == Qnil)
  {
	  array = rb_ary_new();
	  rb_iv_set(self,"@polyCovers",array);

	  rows = polyMap->rows;
	  cols = polyMap->cols;

      for (r = 0; r < rows; r++)
        for (c = 0; c < cols; c++)
        {
          PolyId polyNum = pmapGetP(polyMap,r,c);
          Pixel cover = imageGetP(image,r,c);

          rb_ary_store(array,(long)polyNum,INT2FIX(cover));
		}
  }

  return array;
}


static VALUE t_pIJ(VALUE self, VALUE eightNeighbors, VALUE background)
{
  Image24* image;
  VALUE imageObj, pIJ, neighs, back, nIJ, nI, num, pJI, pI, classes, areas;
  INT32 row, col, rows, cols;
  int len, r, c, occupiedCells, area;

  pIJ = rb_iv_get(self,"@pIJ");
  neighs = rb_iv_get(self,"@pIJneighs");
  back = rb_iv_get(self,"@pIJback");

  // see if we need to calc it
  if ( ((pIJ == Qnil) || (neighs == Qnil) || (back == Qnil))  // not cached
       ||
       ((neighs != eightNeighbors) || (back != background))  // out of date
     )
  {
    ID assignMethod = rb_intern("[]=");
    ID accessMethod = rb_intern("[]");
    ID rowsMethod = rb_intern("rows");

    imageObj = rb_iv_get(self,"@image");
    Data_Get_Struct(imageObj,Image24,image);

    //pIJ = rb_funcall(SparseMatrix,newMethod,0);
    pIJ = rb_eval_string("SparseMatrix.new");
    rb_iv_set(self,"@pIJ",pIJ);
    rb_iv_set(self,"@pIJneighs",eightNeighbors);
    rb_iv_set(self,"@pIJback",background);

    // now do the work
    //nIJ = rb_funcall(SparseMatrix,newMethod,0);
    nIJ = rb_eval_string("SparseMatrix.new");
    nI = rb_hash_new();

    rows = image->rows;
    cols = image->cols;
    for (row = 0; row < rows; row++)  // starting at image bottom
    {
      for (col = 0; col < cols; col++)
      {
        VALUE center = INT2FIX(imageGetP(image,row,col));
        VALUE other = 0;

        if (center == background)
          continue;

        // look right
        if (col < cols-1)
        {
		  other = INT2FIX(imageGetP(image,row,col+1));
		  if (other != background)
		  {
            num = rb_funcall(nIJ,accessMethod,2,center,other);
            if (num == Qnil)
              rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(1));
            else
              rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(FIX2INT(num)+1));
            num = rb_hash_aref(nI,center);
            if (num == Qnil)
              rb_hash_aset(nI,center,INT2FIX(1));
            else
              rb_hash_aset(nI,center,INT2FIX(FIX2INT(num)+1));
            num = rb_funcall(nIJ,accessMethod,2,other,center);
            if (num == Qnil)
              rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(1));
            else
              rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(FIX2INT(num)+1));
            num = rb_hash_aref(nI,other);
            if (num == Qnil)
              rb_hash_aset(nI,other,INT2FIX(1));
            else
              rb_hash_aset(nI,other,INT2FIX(FIX2INT(num)+1));
		  }
        }

        // look up
        if (row < rows-1)
        {
		  other = INT2FIX(imageGetP(image,row+1,col));
		  if (other != background)
		  {
            num = rb_funcall(nIJ,accessMethod,2,center,other);
            if (num == Qnil)
              rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(1));
            else
              rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(FIX2INT(num)+1));
            num = rb_hash_aref(nI,center);
            if (num == Qnil)
              rb_hash_aset(nI,center,INT2FIX(1));
            else
              rb_hash_aset(nI,center,INT2FIX(FIX2INT(num)+1));
            num = rb_funcall(nIJ,accessMethod,2,other,center);
            if (num == Qnil)
              rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(1));
            else
              rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(FIX2INT(num)+1));
            num = rb_hash_aref(nI,other);
            if (num == Qnil)
              rb_hash_aset(nI,other,INT2FIX(1));
            else
              rb_hash_aset(nI,other,INT2FIX(FIX2INT(num)+1));

		  }  // other != background

          if (eightNeighbors == Qtrue)
          {
			  // look up left
			  if (col > 0)
			  {
				other = INT2FIX(imageGetP(image,row+1,col-1));
				if (other != background)
				{
					num = rb_funcall(nIJ,accessMethod,2,center,other);
					if (num == Qnil)
					  rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(1));
					else
					  rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(FIX2INT(num)+1));
					num = rb_hash_aref(nI,center);
					if (num == Qnil)
					  rb_hash_aset(nI,center,INT2FIX(1));
					else
					  rb_hash_aset(nI,center,INT2FIX(FIX2INT(num)+1));
					num = rb_funcall(nIJ,accessMethod,2,other,center);
					if (num == Qnil)
					  rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(1));
					else
					  rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(FIX2INT(num)+1));
					num = rb_hash_aref(nI,other);
					if (num == Qnil)
					  rb_hash_aset(nI,other,INT2FIX(1));
					else
					  rb_hash_aset(nI,other,INT2FIX(FIX2INT(num)+1));

				}  // other != background

			  }  // look up left

			  // look up right
			  if (col < cols-1)
			  {
				other = INT2FIX(imageGetP(image,row+1,col+1));
				if (other != background)
				{
					num = rb_funcall(nIJ,accessMethod,2,center,other);
					if (num == Qnil)
					  rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(1));
					else
					  rb_funcall(nIJ,assignMethod,3,center,other,INT2FIX(FIX2INT(num)+1));
					num = rb_hash_aref(nI,center);
					if (num == Qnil)
					  rb_hash_aset(nI,center,INT2FIX(1));
					else
					  rb_hash_aset(nI,center,INT2FIX(FIX2INT(num)+1));
					num = rb_funcall(nIJ,accessMethod,2,other,center);
					if (num == Qnil)
					  rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(1));
					else
					  rb_funcall(nIJ,assignMethod,3,other,center,INT2FIX(FIX2INT(num)+1));
					num = rb_hash_aref(nI,other);
					if (num == Qnil)
					  rb_hash_aset(nI,other,INT2FIX(1));
					else
					  rb_hash_aset(nI,other,INT2FIX(FIX2INT(num)+1));

				}  // other != background

			  } // look up right

	      }  // if eight neighs

        }  // look up

      }  // for each col on map check adjacencies

    }  // for each row

    //pJI = rb_funcall(SparseMatrix,newMethod,0);
    pJI = rb_eval_string("SparseMatrix.new");

    classes = rb_funcall(nIJ,rowsMethod,0);

    len = RARRAY(classes)->len;
    for (r = 0; r < len; r++)
    {
      VALUE rowEntry = rb_ary_entry(classes,r);
      VALUE num1 = rb_hash_aref(nI,rowEntry);

      for (c = 0; c < len; c++)
      {
        VALUE colEntry = rb_ary_entry(classes,c);

        if ((num1 != Qnil) && (FIX2INT(num1) > 0))
        {
          VALUE num12 = rb_funcall(nIJ,accessMethod,2,rowEntry,colEntry);
          if (num12 != Qnil)
		    rb_funcall(pJI,assignMethod,3,rowEntry,colEntry,rb_float_new(((double)FIX2INT(num12))/FIX2INT(num1)));
          else
		    rb_funcall(pJI,assignMethod,3,rowEntry,colEntry,rb_float_new(0.0));
	    }
	    else
		  rb_funcall(pJI,assignMethod,3,rowEntry,colEntry,rb_float_new(0.0));


	  }  // for each class type as col

    }  // for each class type as row

    areas = t_areas(self);
    occupiedCells = FIX2INT(t_area(self));
    if (FIX2INT(background) != -1)
    {
	  VALUE backArea = rb_ary_entry(areas,FIX2INT(background));
	  if (backArea != Qnil)
	    occupiedCells -= FIX2INT(backArea);
	}

	pI = rb_hash_new();
    for (r = 0; r < len; r++)
    {
      VALUE color = rb_ary_entry(classes,r);

      VALUE tmp = rb_ary_entry(areas,FIX2INT(color));
      if (tmp == Qnil)
        area = 0;
      else
        area = FIX2INT(tmp);

      if (occupiedCells > 0)
        rb_hash_aset(pI,color,rb_float_new(((double)area) / occupiedCells));
    }

    // finally set pIJ
    for (r = 0; r < len; r++)
    {
      VALUE rowEntry = rb_ary_entry(classes,r);
      for (c = 0; c < len; c++)
      {
        VALUE colEntry = rb_ary_entry(classes,c);

        double probFind = RFLOAT(rb_hash_aref(pI,rowEntry))->value;
        double probAdj  = RFLOAT(rb_funcall(pJI,accessMethod,2,rowEntry,colEntry))->value;
        double prob = probFind * probAdj;

        rb_funcall(pIJ,assignMethod,3,rowEntry,colEntry,rb_float_new(prob));
      }
    }

  }  // calc pIJ

  return pIJ;
}

// Exported functions

void Init_Image24(void)
{
  VALUE val = rb_require("SparseMatrix.rb");
  cImage24 = rb_define_class("Image24",rb_cObject);
  rb_define_method(cImage24, "initialize", t_init, 2);
  rb_define_method(cImage24, "specify", t_specify, 2);
  rb_define_method(cImage24, "getCell", t_getCell, 2);
  rb_define_method(cImage24, "setCell", t_setCell, 3);
  rb_define_method(cImage24, "rows", t_rows, 0);
  rb_define_method(cImage24, "cols", t_cols, 0);
  rb_define_method(cImage24, "classesPresent", t_classesPresent, 0);
  rb_define_method(cImage24, "legend", t_legend, 0);
  rb_define_method(cImage24, "palette", t_palette, 0);
  rb_define_method(cImage24, "title", t_title, 0);
  rb_define_method(cImage24, "title=", t_setTitle, 1);
  rb_define_method(cImage24, "each", t_each, 0);
  rb_define_method(cImage24, "each5", t_each5, 0);
  rb_define_method(cImage24, "each9", t_each9, 0);
  rb_define_method(cImage24, "polyCount", t_polyCount, 1);
  rb_define_method(cImage24, "polyAreas", t_polyAreas, 1);
  rb_define_method(cImage24, "polyPerims", t_polyPerims, 1);
  rb_define_method(cImage24, "polyClasses", t_polyClasses, 1);
  rb_define_method(cImage24, "area", t_area, 0);
  rb_define_method(cImage24, "perimeter", t_perimeter, 0);
  rb_define_method(cImage24, "areas", t_areas, 0);
  rb_define_method(cImage24, "perimeters", t_perimeters, 0);
  rb_define_method(cImage24, "pIJ", t_pIJ, 2);
}

