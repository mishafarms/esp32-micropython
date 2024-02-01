import fs = require('fs');
import path = require('path');
import pump = require('pump');
import del = require('del');
import gulp = require('gulp');
import uglify = require('gulp-uglify');
import debug = require('gulp-debug');
import gzip = require('gulp-gzip');
import gulpif = require('gulp-if');

interface argType {
  target: string
}
// fetch command line arguments
const arg: Record<string, any> = (argList => {

  let arg: Record<string, any> = {}, a, opt, thisOpt, curOpt;
  for (a = 0; a < argList.length; a++) {

    thisOpt = argList[a].trim();
    opt = thisOpt.replace(/^\-+/, '');

    if (opt === thisOpt) {

      // argument value
      if (curOpt) arg[curOpt] = opt;
      curOpt = null;

    } else {

      // argument name
      curOpt = opt;
      arg[curOpt] = true;

    }
  }

  return arg;

})(process.argv);


const CorePath = path.join(__dirname, 'sys');

const PanelPath = path.join(__dirname, 'panel', 'dist');

const EduBlocksPath = path.join(__dirname, '..', 'edublocks-micropython', 'web');

const OttoPythonPath = path.join(__dirname, '..', 'OttoDIYPython');

const OttoWebPath = path.join(__dirname, '..', 'OttoDIYPython', 'web');

const TempSensorPythonPath = path.join(__dirname, '..', 'tempSensor');

const TempSensorWebPath = path.join(__dirname, '..', 'tempSensor', 'web');

const dest = path.join(__dirname, 'sys-fs');

const ExtNoGzip = ['.py', '.xml', '.mp3', '.wav', '.json', '.bmp']

/*const compressionStages = () => [
  gulpif((f) => f.extname === '.js', uglify()),
  gulpif((f) => ExtNoGzip.indexOf(f.extname) === -1, gzip({ gzipOptions: { level: 9 } })),
];
*/
const compressionStages = () => [
  gulpif((f) => !f.path.endsWith('.min.js') && f.path.endsWith('.js'), uglify()),
  gulpif((f) => ExtNoGzip.indexOf(f.extname) === -1, gzip({ gzipOptions: { level: 9 } })),
];

gulp.task('clean', () => {
  return del([path.join(dest, '*')]);
});

gulp.task('bundle-core', () => {
  return pump([
    gulp.src([`${CorePath}/**/*.*`], { base: CorePath }),
    debug({ title: 'bundle-core' }),
    ...compressionStages(),
    gulp.dest(dest),
  ]);
});

gulp.task('bundle-panel', () => {
  return pump([
    gulp.src([`${PanelPath}/**/*.*`], { base: PanelPath }),
    debug({ title: 'bundle-panel' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'web')),
  ]);
});

gulp.task('bundle-edublocks', () => {
  const assetsJsonPath = path.join(EduBlocksPath, '..', 'assets.json');

  if (!fs.existsSync(assetsJsonPath)) {
    // throw new Error('EduBlocks source not found!');

    return pump([]);
  }

  const assets: string[] = JSON.parse(fs.readFileSync(assetsJsonPath, 'utf-8'));

  const assetPaths = assets.map((asset) => path.join(EduBlocksPath, asset));

  return pump([
    gulp.src(assetPaths, { base: EduBlocksPath }),
    debug({ title: 'bundle-edublocks' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'web')),
  ]);
});

gulp.task('bundle-otto-python', () => {
  return pump([
    gulp.src([`${OttoPythonPath}/*.py`], { base: OttoPythonPath }),
    debug({ title: 'bundle-ottopython' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'lib')),
  ]);
});

gulp.task('bundle-otto-web', () => {
  const assetsJsonPath = path.join(OttoWebPath, '..', 'assets.json');

  if (!fs.existsSync(assetsJsonPath)) {
    // throw new Error('EduBlocks source not found!');

    return pump([]);
  }

  const assets: string[] = JSON.parse(fs.readFileSync(assetsJsonPath, 'utf-8'));

  const assetPaths = assets.map((asset) => path.join(OttoWebPath, asset));

  return pump([
    gulp.src(assetPaths, { base: OttoWebPath }),
    debug({ title: 'bundle-ottoweb' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'web')),
  ]);
});

gulp.task('bundle-tempSensor-python', () => {
  return pump([
    gulp.src([`${TempSensorPythonPath}/*.py`], { base:TempSensorPythonPath }),
    debug({ title: 'bundle-tempSensor-python' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'lib')),
  ]);
});

gulp.task('bundle-tempSensor-web', () => {
  const assetsJsonPath = path.join(TempSensorWebPath, '..', 'assets.json');

  if (!fs.existsSync(assetsJsonPath)) {
    // throw new Error('EduBlocks source not found!');

    return pump([]);
  }

  const assets: string[] = JSON.parse(fs.readFileSync(assetsJsonPath, 'utf-8'));

  const assetPaths = assets.map((asset) => path.join(TempSensorWebPath, asset));

  return pump([
    gulp.src(assetPaths, { base: TempSensorWebPath }),
    debug({ title: 'bundle-tempSensor-web' }),
    ...compressionStages(),
    gulp.dest(path.join(dest, 'web')),
  ]);
});

gulp.task('default', gulp.series(['clean', 'bundle-core', 'bundle-panel', 'bundle-edublocks']));
gulp.task('otto', gulp.series(['clean', 'bundle-core', 'bundle-panel', 'bundle-edublocks', 'bundle-otto-python', 'bundle-otto-web']));
gulp.task('tempSensor', gulp.series(['clean', 'bundle-core', 'bundle-panel', 'bundle-tempSensor-python', 'bundle-tempSensor-web']));

gulp.task('target-web', () => {
  let targetWebPath = "";

  if (arg['target']) {
    targetWebPath = path.join(__dirname, '..', arg['target'], 'web');
  }
  else {
    // throw new Error('Target not found in args!');
    debug({title: 'target not passed in args'});
    throw new Error('Target not passed in args');
  }

  const assetsJsonPath = path.join(targetWebPath, '..', 'assets.json');

  if (!fs.existsSync(assetsJsonPath)) {
    // throw new Error('EduBlocks source not found!');

    debug({title: 'asset file not found'});
    throw new Error('asset file not found');
  }

  const assets: string[] = JSON.parse(fs.readFileSync(assetsJsonPath, 'utf-8'));

  const assetPaths = assets.map((asset) => path.join(targetWebPath, asset));

  return pump([
      gulp.src(assetPaths, { base: targetWebPath }),
      debug({title: 'bundel-' + targetWebPath}),
      ...compressionStages(),
      gulp.dest(path.join(dest, 'web')),
  ]);
})

gulp.task('target-python', () => {
  let targetPythonPath = "";

  if (arg['target']) {
    targetPythonPath = path.join(__dirname, '..', arg['target']);

    return pump([
      gulp.src([`${targetPythonPath}/*.py`], {base: targetPythonPath}),
      debug({title: 'bundle-' + arg['target'] + '- Python'}),
      ...compressionStages(),
      gulp.dest(path.join(dest, 'lib')),
    ]);
  }
  else {
    // throw new Error('Target not found in args!');
    debug({title: 'target not passed in args'});
    throw new Error('Target not passed in args');
  }
})

gulp.task('targetTask', gulp.series(['clean', 'bundle-core', 'bundle-panel', 'target-python', 'target-web']));