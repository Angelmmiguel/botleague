import java.util.*;

public class AndresBot {
    public static void main(String[] args) throws java.io.IOException {

        final InitPackage iPackage = Networking.getInit();
        final int myID = iPackage.myID;
        final GameMap gameMap = iPackage.map;

        Networking.sendInit("AndresBot");

        List<Location> enemies = new ArrayList<>();

        while (true) {
            List<Move> moves = new ArrayList<>();

            Networking.updateFrame(gameMap);

            for (int y = 0; y < gameMap.height; y++) {
                for (int x = 0; x < gameMap.width; x++) {
                    Location location = gameMap.getLocation(x, y);

                    if (location.getSite().owner == myID) {
                        Map<Direction, Site> aroundMe = new HashMap<>();

                        if (x != gameMap.width - 1) {
                            Location east = gameMap.getLocation(x + 1, y);
                            if (gameMap.inBounds(east)) {
                                aroundMe.put(Direction.EAST, east.getSite());
                            }
                        }

                        if (x != 0) {
                            Location west = gameMap.getLocation(x - 1, y);
                            if (gameMap.inBounds(west)) {
                                aroundMe.put(Direction.WEST, west.getSite());
                            }
                        }

                        if (y != 0) {
                            Location north = gameMap.getLocation(x, y - 1);
                            if (gameMap.inBounds(north)) {
                                aroundMe.put(Direction.NORTH, north.getSite());
                            }
                        }

                        if (y != gameMap.height - 1) {
                            Location south = gameMap.getLocation(x, y + 1);
                            if (gameMap.inBounds(south)) {
                                aroundMe.put(Direction.SOUTH, south.getSite());
                            }
                        }


                        Optional<Map.Entry<Direction, Site>> betterOpts = aroundMe.entrySet().stream()
                                .filter(Objects::nonNull)
                                .filter(entry -> entry.getValue().owner != myID)
                                .reduce((e1, e2) -> {
                                    if (e1.getValue().strength > e2.getValue().strength) {
                                        return e2;
                                    } else {
                                        return e1;
                                    }
                                });

                        if (betterOpts.isPresent()) {
                            if (betterOpts.get().getValue().strength > location.getSite().strength) {
                                moves.add(new Move(location, Direction.STILL));
                            } else {
                                moves.add(new Move(location, betterOpts.get().getKey()));
                            }
                        } else {
                            if (enemies.isEmpty()) {
                                moves.add(new Move(location, Direction.STILL));
                            } else {
                                Location bad = enemies.get(0);
                                Location newLoc = gameMap.getLocation(bad.getX(), bad.getY());
                                if (newLoc.getSite().owner == myID) {
                                    enemies.remove(0);
                                } else {
                                    Double angle = gameMap.getAngle(location, newLoc);
                                    if (angle <= 45 || angle >= 315) {
                                        moves.add(new Move(location, Direction.EAST));
                                    } else if (angle > 45 && angle <= 135) {
                                        moves.add(new Move(location, Direction.NORTH));
                                    } else if (angle > 135 && angle <= 225) {
                                        moves.add(new Move(location, Direction.WEST));
                                    } else if (angle > 225 && angle <= 315) {
                                        moves.add(new Move(location, Direction.SOUTH));
                                    }
                                }
                            }
                        }
                    } else {
                        enemies.add(location);
                    }
                }
            }
            Networking.sendFrame(moves);
        }
    }
}
