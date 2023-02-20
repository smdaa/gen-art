#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/Perlin.h"
#include "cinder/ImageIo.h"
#include "cinder/Utilities.h"

using namespace ci;
using namespace ci::app;

#define PI 3.14159265358979323846

// Window dimensions in pixels
const int windowSizeX = 1920;
const int windowSizeY = 1080;
const int marginSize = 100;
const int gridResolution = 10;

// Arrow grid sizes
const float arrowLength = 15.0f;
const float headLength = 6.0f;
const float headRadius = 3.0f;

// Grid
const int nRows = (int)(windowSizeY + marginSize) / gridResolution;
const int nColumns = (int)(windowSizeX + marginSize) / gridResolution;
float **Grid;

// Points
const int nPoints = 10000;
int **Points;

// Array for points at time t-1
int **oldPoints;

// step length update
const float step_length = 5;

// Perlin noise generator
Perlin mPerlin = Perlin();

bool mMakeScreenshot;


class FlowFieldApp : public App
{
public:
	void keyDown( KeyEvent event ) override;
	void draw() override;
	void setup() override;
	void update() override;

	void initGrid();
	void updateGrid();
	void drawGrid();

	void initPoints();
	void updatePoint(int *x, int *y);
	void updatePoints();
	void drawPoints();
};

void FlowFieldApp::initGrid()
{

	Grid = new float *[nRows];
	for (int i = 0; i < nRows; i++)
	{
		Grid[i] = new float[nColumns];

		for (int j = 0; j < nColumns; j++)
		{

			Grid[i][j] = mPerlin.noise(((float)i) * 0.1f, ((float)j) * 0.1f) * PI * 2.0f;
		}
	}
}

void FlowFieldApp::updateGrid()
{
	for (int i = 0; i < nRows; i++)
	{
		for (int j = 0; j < nColumns; j++)
		{
			Grid[i][j] = mPerlin.noise(((float)i) * 0.1f, ((float)j) * 0.1f, (float)app::getElapsedSeconds() * 0.1f) * PI * 2.0f;
		}
	}
}

void FlowFieldApp::drawGrid()
{
	for (int i = 0; i < nRows; i++)
	{
		for (int j = 0; j < nColumns; j++)
		{
			float angle = Grid[i][j];
			float y = (i * gridResolution);
			float x = (j * gridResolution);

			vec3 p1(x, y, 0.0f);
			vec3 p2(x + arrowLength * cos(angle), y + arrowLength * sin(-angle), 0.0f);

			gl::drawVector(p1, p2, headLength, headRadius);
		}
	}
}

void FlowFieldApp::initPoints()
{
	Points = new int *[nPoints];
	oldPoints = new int *[nPoints];

	for (int i = 0; i < nPoints; i++)
	{
		Points[i] = new int[2];
		oldPoints[i] = new int[2];

		Points[i][0] = 0;
		Points[i][1] = rand() % (windowSizeY + marginSize);

		oldPoints[i][0] = Points[i][0];
		oldPoints[i][1] = Points[i][1];
	}
}

void FlowFieldApp::updatePoints()
{
	int rowIndex;
	int columnIndex;

	for (int i = 0; i < nPoints; i++)
	{
		oldPoints[i][0] = Points[i][0];
		oldPoints[i][1] = Points[i][1];

		rowIndex = std::min((int)Points[i][1] / gridResolution, nRows - 1);
		columnIndex = std::min((int)Points[i][0] / gridResolution, nColumns - 1);

		float angle = Grid[rowIndex][columnIndex];
		float x_step = step_length * cos(angle);
		float y_step = step_length * sin(-angle);

		Points[i][0] = (int)Points[i][0] + x_step;
		Points[i][1] = (int)Points[i][1] + y_step;

		if (Points[i][0] > windowSizeX + marginSize or Points[i][1] > windowSizeY + marginSize or Points[i][0] < 0 or Points[i][1] < 0)
		{
			Points[i][0] = 0;
			Points[i][1] = rand() % (windowSizeY + marginSize);

			oldPoints[i][0] = Points[i][0];
			oldPoints[i][1] = Points[i][1];
		}
	}
}

void FlowFieldApp::drawPoints()
{

	gl::enableAlphaBlending();
	gl::color(ci::ColorA(1.0, 1.0, 1.0, 0.01));
	for (int i = 0; i < nPoints; i++)
	{
		vec2 p1(oldPoints[i][0] - (int)marginSize / 2, oldPoints[i][1] - (int)marginSize / 2);
		vec2 p2(Points[i][0] - (int)marginSize / 2, Points[i][1] - (int)marginSize / 2);
		gl::drawLine(p1, p2);
	}
	gl::end();
}

void prepareSettings(FlowFieldApp::Settings *settings)
{

	settings->setMultiTouchEnabled(false);
	settings->setWindowSize(windowSizeX, windowSizeY);
	settings->setFrameRate(60);
}

void FlowFieldApp::keyDown(KeyEvent event)
{
	if (event.getChar() == 's')
	{
		mMakeScreenshot = true;
	}
}

void FlowFieldApp::setup()
{
	initGrid();
	initPoints();
}

void FlowFieldApp::update()
{
	updatePoints();
	updateGrid();
}

void FlowFieldApp::draw()
{

	drawPoints();
	if (mMakeScreenshot)
	{
		mMakeScreenshot = false;
		writeImage(fs::path("./MainApp_screenshot.png"), copyWindowSurface());
		std::cout << getDocumentsDirectory() / fs::path("MainApp_screenshot.png") << "\n";
	}
}

CINDER_APP(FlowFieldApp, RendererGl, prepareSettings)
