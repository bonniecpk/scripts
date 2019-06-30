package main

import (
	"fmt"
	"time"
)

type board [][]colorPoint

const (
	north = iota
	east
	south
	west

	right = 1
	left  = -1
)

type game struct {
	board
	ant
}

type ant struct {
	x, y, direction int
}

type colorPoint struct {
	black bool
}

func createBoard(size int) board {
	nb := make([][]colorPoint, size)
	for i := range nb {
		nb[i] = make([]colorPoint, size)
	}
	return board(nb)
}

func (g *game) start() {
	ant := &g.ant
	for {
		if g.antAtWhite() {
			ant.turn(right)
		} else {
			ant.turn(left)
		}
		g.board.flipColor(*ant)
		ant.move(1)
		g.print()
		time.Sleep(time.Second)
	}
}

func (g *game) antAtWhite() bool {
	return !g.board[g.ant.x][g.ant.y].black
}

func (a *ant) turn(angle int) {
	if angle == right {
		if a.direction == west {
			a.direction = north
		} else {
			a.direction += 1
		}
	} else {
		if a.direction == north {
			a.direction = west
		} else {
			a.direction -= 1
		}
	}
}

func (b *board) flipColor(a ant) {
	(*b)[a.x][a.y].black = !(*b)[a.x][a.y].black
}

func (a *ant) move(steps int) {
	if a.direction == north {
		a.x -= steps
	} else if a.direction == east {
		a.y += steps
	} else if a.direction == south {
		a.x += steps
	} else {
		a.y -= steps
	}
}

func (g *game) print() {
	for x, yl := range g.board {
		for y, point := range yl {
			if g.ant.x == x && g.ant.y == y {
				fmt.Print("*")
			} else if point.black {
				fmt.Print("`")
			} else {
				fmt.Print("-")
			}
		}
		fmt.Print("\n")
	}
	fmt.Println("\n")
}

func main() {
	game := game{
		board: createBoard(10),
		ant:   ant{x: 4, y: 4, direction: north}}
	game.start()
}
