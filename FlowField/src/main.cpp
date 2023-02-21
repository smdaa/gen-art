#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/Perlin.h"


using namespace ci;
using namespace ci::app;

#define PI 3.14159265358979323846

// Window dimensions in pixels
const int windowSizeX = 1920;
const int windowSizeY = 1080;
const int marginSize = 100;
const int gridResolution = 5;

// Arrow grid sizes
const float arrowLength = 15.0f;
const float headLength = 6.0f;
const float headRadius = 3.0f;

// Grid
const int nRows = (int)(windowSizeY + marginSize) / gridResolution;
const int nColumns = (int)(windowSizeX + marginSize) / gridResolution;
float **Grid;

// Points
const int nPoints = 2000;
vec2 *Points;

// 2d Paths
Path2d *Paths;

// colors
ColorA * Colors;

// step length update
const float step_length = 20;

// Perlin noise generator
Perlin mPerlin = Perlin();

class FlowFieldApp : public App
{
public:
	void draw() override;
	void setup() override;
	void update() override;

	void initGrid();
	void updateGrid();
	void drawGrid();

	void initPoints();
	void updatePoints();
	void drawPoints();

	void initPaths();
	void initColors(const ColorA& startColor, const ColorA& endColor);
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
			Grid[i][j] = mPerlin.noise(((float)i) * 0.01f, ((float)j) * 0.01f, (float)app::getElapsedSeconds() * 0.5f) * PI * 1.0f;
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
	Points = new vec2[nPoints];

	for (int i = 0; i < nPoints; i++)
	{
		Points[i] = vec2(0.0f, rand() % (windowSizeY + marginSize));
	}
}

void FlowFieldApp::updatePoints()
{
	int rowIndex;
	int columnIndex;

	for (int i = 0; i < nPoints; i++)
	{

		rowIndex = std::min((int)Points[i][1] / gridResolution, nRows - 1);
		columnIndex = std::min((int)Points[i][0] / gridResolution, nColumns - 1);
		float angle = Grid[rowIndex][columnIndex];
		vec2 step = vec2(step_length * cos(angle), step_length * sin(-angle));
		Points[i] = Points[i] + step;

		if (Points[i][0] > windowSizeX + marginSize or Points[i][1] > windowSizeY + marginSize or Points[i][0] < 0 or Points[i][1] < 0)
		{

			Points[i] = vec2(0.0f, rand() % (windowSizeY + marginSize));
			Paths[i] = Path2d();
			Paths[i].moveTo(Points[i]);
		}
	}
}

void FlowFieldApp::drawPoints()
{

	gl::enableAlphaBlending();
	for (int i = 0; i < nPoints; i++)
	{
		Paths[i].lineTo(Points[i]);
		gl::lineWidth(2.0);
		gl::color(Colors[i]);
		gl::draw(Paths[i]);
		
	}
}

void FlowFieldApp::initPaths()
{
	Paths = new Path2d[nPoints];
	for (int i = 0; i < nPoints; i++)
	{
		Paths[i].moveTo(Points[i]);
	}
}

void FlowFieldApp::initColors(const ColorA& startColor, const ColorA& endColor){
	float rStep = static_cast<float>(endColor.r - startColor.r) / (nPoints - 1);
	float gStep = static_cast<float>(endColor.g - startColor.g) / (nPoints - 1);
	float bStep = static_cast<float>(endColor.b - startColor.b) / (nPoints - 1);

	Colors = new ColorA[nPoints];
	for (int i = 0; i < nPoints; i++) {
        Colors[i].r = startColor.r + rStep * i;
        Colors[i].g = startColor.g + gStep * i;
        Colors[i].b = startColor.b + bStep * i;
		Colors[i].a = 0.05;
    }

}

void prepareSettings(FlowFieldApp::Settings *settings)
{

	settings->setMultiTouchEnabled(false);
	settings->setWindowSize(windowSizeX, windowSizeY);
	settings->setFrameRate(60);
}

void FlowFieldApp::setup()
{
	initGrid();
	initPoints();
	initPaths();
	initColors(ColorA(1.0, 0.27, 0.27),ColorA(0.69, 0.36, 0.98));
}

void FlowFieldApp::update()
{
	updatePoints();
	updateGrid();
}

void FlowFieldApp::draw()
{
	gl::clear();
	//drawGrid();
	drawPoints();
	gl::end();
}

CINDER_APP(FlowFieldApp, RendererGl(RendererGl::Options().msaa(8)), prepareSettings)
