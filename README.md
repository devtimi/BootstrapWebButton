# BootstrapWebButton
Xojo WebButton subclass that allows icons. This class modifies the caption of the button using the ``<raw></raw>`` tags to insert html that will display an icon in the button. The class supports both built in Bootstrap icons and FontAwesome 5 icons.

## Usage
To display an icon on a `BootstrapWebButton` instance select the Icon Type and Icon Name. Bootstrap icons will pass the icon name to Xojo's `WebPicture.BoostrapIcon` function. FontAwesome icons will automatically prefix, enter only the icon name as it is displayed in the icon list (without `fas fa-`).

### Default Sizes
By default, the BootstrapWebButton will use the global font size. This can be overriden with the `LabelSize` and `IconSize` properties. To use the default sizes, set `LabelSize` and/or `IconSize` to `0`.

### Colors
The button will use default global coloring for the label and icon. This can be overriden by selecting a color and setting the `HasLabelColor` or `HasIconColor` property `true`.

### Font Awesome Pro Icons
The class has been tested with the free versions of FontAwesome icons, though pro icons are expected to work. To load pro icons the FontAwesome CSS link will need to be changed in the Javascript loading source. This is stored in the `kFontAwesomeLoadJS` constant.

## Authors
Original class: Bruno Frechette - bruno@newmood.com

Automagic CSS: Tim Parnell - strawberrysw.com

Inspired by posts from Brock Nash

## License
This class can be modified at will, is reusable, distributable, for commercial or any other use.

This class is distributed as "beerware". If you find this class useful and want to express your gratitude, buy us a beer at the next Xojo conference or send a few dollars through PayPal at bruno@newmood.com. If you do, I'll send you a picture of the beer I drank with your donation.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.