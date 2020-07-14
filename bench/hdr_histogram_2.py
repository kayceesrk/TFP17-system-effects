import matplotlib
import numpy as np
from numpy import ma
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter
import matplotlib.patches as mpatches
import subprocess
from matplotlib import scale as mscale
from matplotlib import transforms as mtransforms
from matplotlib.ticker import FixedFormatter, FixedLocator

class CloseToOne(mscale.ScaleBase):
    name = 'close_to_one'

    def __init__(self, axis, **kwargs):
        mscale.ScaleBase.__init__(self)
        self.nines = kwargs.get('nines', 5)

    def get_transform(self):
        return self.Transform(self.nines)

    def set_default_locators_and_formatters(self, axis):
        axis.set_major_locator(FixedLocator(
                np.array([1-10**(-k) for k in range(1+self.nines)])))
        axis.set_major_formatter(FixedFormatter(
                [str(100 * (1-10**(-k))) + "%" for k in range(1+self.nines)]))


    def limit_range_for_scale(self, vmin, vmax, minpos):
        return vmin, min(1 - 10**(-self.nines), vmax)

    class Transform(mtransforms.Transform):
        input_dims = 1
        output_dims = 1
        is_separable = True

        def __init__(self, nines):
            mtransforms.Transform.__init__(self)
            self.nines = nines

        def transform_non_affine(self, a):
            masked = ma.masked_where(a > 1-10**(-1-self.nines), a)
            if masked.mask.any():
                return -ma.log10(1-a)
            else:
                return -np.log10(1-a)

        def inverted(self):
            return CloseToOne.InvertedTransform(self.nines)

    class InvertedTransform(mtransforms.Transform):
        input_dims = 1
        output_dims = 1
        is_separable = True

        def __init__(self, nines):
            mtransforms.Transform.__init__(self)
            self.nines = nines

        def transform_non_affine(self, a):
            return 1. - 10**(-a)

        def inverted(self):
            return CloseToOne.Transform(self.nines)

mscale.register_scale(CloseToOne)

matplotlib.rcParams['ps.fonttype'] = 42
matplotlib.rcParams['pdf.fonttype'] = 42

nodeKind = ['-', '--', '-.', '^:', 'X-', 'V--', '>-.', '<:']

def parse (f):
  infile = open (f, "r")
  started = False
  data = []
  for line in infile.readlines ():
    if not started:
      if line.strip().startswith("Value"):
        started = True
    else:
      if line.strip().startswith("#"):
        return data
      elif len (line.strip()) == 0:
        continue
      else:
        d = line.split()
        data.append((float(d[1]), float(d[0])))

def plot_line (f,s,nk):
  data = parse(f)
  (x,y) = zip(*data)
  plt.plot (x,y,nodeKind[nk],label=s)

def plot_graph(s):
  plt.ylabel("Lantency (ms)")
  plt.grid (True)
  plt.axes().set_xscale ("close_to_one", nines=5)
  plot_line("async_" + s + ".dat", "Async", 0)
  plot_line("go_" + s + ".dat", "Go", 1)
  plot_line("effects_" + s + ".dat", "Effects", 2)
  plt.legend ()
  plt.show ()
  plt.close ()

def main ():
  font = {'family' : 'normal', 'weight' : 'normal', 'size' : 14}
  matplotlib.rc('font', **font)
  # Graph 2
  plot_graph("d30_t2_c10k_R30k")


main()
